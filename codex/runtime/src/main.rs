// SnapKitty Opaque License
// Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
// Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

//! Production-oriented Codex runtime.
//! Ephemeral workers, hard budgets, cancellation, no shared mutable KV.

pub mod mock;
pub mod ffi;

use std::sync::atomic::{AtomicBool, AtomicU32, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

#[derive(Debug, Clone)]
pub struct WorkerConfig {
    pub task_id: String,
    pub budget_tokens: i32,
    pub deadline_ms: u64,
    pub context: String,
}

#[derive(Debug)]
pub struct WorkerResult {
    pub task_id: String,
    pub output: String,
    pub token_count: i32,
    pub wall_time_ms: u64,
    pub valid: bool,
}

#[derive(Debug)]
pub enum WorkerError {
    Cancelled,
    BudgetExceeded,
    DeadlineExceeded,
}

pub struct InferenceWorker {
    config: WorkerConfig,
    cancelled: Arc<AtomicBool>,
    tokens: Arc<AtomicU32>,
    start: Instant,
}

impl InferenceWorker {
    pub fn new(config: WorkerConfig) -> Self {
        Self {
            config,
            cancelled: Arc::new(AtomicBool::new(false)),
            tokens: Arc::new(AtomicU32::new(0)),
            start: Instant::now(),
        }
    }

    pub fn generate(&self) -> Result<WorkerResult, WorkerError> {
        let deadline = Duration::from_millis(self.config.deadline_ms);
        let mut out = String::new();

        while (self.tokens.load(Ordering::SeqCst) as i32) < self.config.budget_tokens {
            if self.cancelled.load(Ordering::SeqCst) {
                return Err(WorkerError::Cancelled);
            }
            if self.start.elapsed() > deadline {
                return Err(WorkerError::DeadlineExceeded);
            }
            out.push_str(&mock::MockBackend::new(self.tokens.load(Ordering::SeqCst) as u64).generate_token());
            out.push(' ');
            self.tokens.fetch_add(1, Ordering::SeqCst);
        }

        let wall = self.start.elapsed().as_millis() as u64;
        Ok(WorkerResult {
            task_id: self.config.task_id.clone(),
            output: out.trim().to_string(),
            token_count: self.tokens.load(Ordering::SeqCst) as i32,
            wall_time_ms: wall,
            valid: true,
        })
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn respects_budget() {
        let w = InferenceWorker::new(WorkerConfig {
            task_id: "t".into(),
            budget_tokens: 3,
            deadline_ms: 1000,
            context: "c".into(),
        });
        let r = w.generate().unwrap();
        assert_eq!(r.token_count, 3);
    }

    #[test]
    fn cancel_stops() {
        let w = InferenceWorker::new(WorkerConfig {
            task_id: "t".into(),
            budget_tokens: 1000,
            deadline_ms: 5000,
            context: "c".into(),
        });
        w.cancel();
        assert!(matches!(w.generate(), Err(WorkerError::Cancelled)));
    }
}

fn main() {
    let cfg = WorkerConfig {
        task_id: "prod-demo".into(),
        budget_tokens: 8,
        deadline_ms: 1000,
        context: "slice".into(),
    };
    let w = InferenceWorker::new(cfg);
    match w.generate() {
        Ok(r) => println!("OK {} tokens in {}ms", r.token_count, r.wall_time_ms),
        Err(e) => eprintln!("ERR {:?}", e),
    }
}
