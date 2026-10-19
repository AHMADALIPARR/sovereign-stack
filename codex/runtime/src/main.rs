//! Codex inference worker runtime.
//! Ephemeral sessions, token/memory budgets, cancellation, mock + llama.cpp backends.

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
    tokens_generated: Arc<AtomicU32>,
    start: Instant,
}

impl InferenceWorker {
    pub fn new(config: WorkerConfig) -> Self {
        Self {
            config,
            cancelled: Arc::new(AtomicBool::new(false)),
            tokens_generated: Arc::new(AtomicU32::new(0)),
            start: Instant::now(),
        }
    }

    pub fn generate(&self) -> Result<WorkerResult, String> {
        let mut output = String::new();

        while self.tokens_generated.load(Ordering::SeqCst) as i32 < self.config.budget_tokens {
            if self.cancelled.load(Ordering::SeqCst) {
                return Err("cancelled".into());
            }

            // Mock token generation (replace with llama.cpp FFI)
            output.push_str("token ");
            self.tokens_generated.fetch_add(1, Ordering::SeqCst);
        }

        let wall = self.start.elapsed().as_millis() as u64;
        let count = self.tokens_generated.load(Ordering::SeqCst) as i32;

        Ok(WorkerResult {
            task_id: self.config.task_id.clone(),
            output: output.trim().to_string(),
            token_count: count,
            wall_time_ms: wall,
            valid: true, // real validation happens in grammar layer
        })
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
    }
}

fn main() {
    let config = WorkerConfig {
        task_id: "demo".into(),
        budget_tokens: 8,
        deadline_ms: 1000,
        context: "test".into(),
    };
    let worker = InferenceWorker::new(config);
    match worker.generate() {
        Ok(r) => println!("OK: {} tokens in {}ms", r.token_count, r.wall_time_ms),
        Err(e) => eprintln!("ERR: {}", e),
    }
}
