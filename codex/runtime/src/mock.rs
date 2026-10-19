// SnapKitty Opaque License
// Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
// Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

//! Mock backend for deterministic testing without GPU.
//! Seeded so Agent 3 can rely on reproducible output.

use std::sync::atomic::{AtomicU64, Ordering};

static SEED: AtomicU64 = AtomicU64::new(42);

pub struct MockBackend {
    pub worker_id: u64,
}

impl MockBackend {
    pub fn new(worker_id: u64) -> Self {
        Self { worker_id }
    }

    pub fn generate_token(&self) -> String {
        let n = SEED.fetch_add(1, Ordering::SeqCst);
        format!("tok{}", n % 8)
    }
}
