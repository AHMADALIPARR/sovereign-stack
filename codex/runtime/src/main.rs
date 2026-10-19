//! Codex runtime — ephemeral workers, budgets, cancellation, mock backend.
//! KV-cache is never shared across workers (I7).

pub mod mock;
pub mod ffi;

use std::sync::atomic::{AtomicBool, AtomicU32, Ordering};
use std::sync::Arc;
use std::time::Instant;

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

    pub fn generate(&self) -> Result<WorkerResult, String> {
        let mut out = String::new();
        while (self.tokens.load(Ordering::SeqCst) as i32) < self.config.budget_tokens {
            if self.cancelled.load(Ordering::SeqCst) {
                return Err("cancelled".into());
            }
            out.push_str(&mock::MockBackend::new(1).generate_token());
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

fn main() {
    let cfg = WorkerConfig {
        task_id: "demo".into(),
        budget_tokens: 4,
        deadline_ms: 500,
        context: "slice".into(),
    };
    let w = InferenceWorker::new(cfg);
    println!("{:?}", w.generate());
}
