//! Documented C ABI surface for llama.cpp integration.
//! Real bindings live behind this contract; mock satisfies it for Half One.

pub mod llama {
    #[repr(C)]
    pub struct LlamaContext {
        pub n_ctx: i32,
        pub n_batch: i32,
    }

    // In production these are extern "C" to llama.cpp
    pub fn llama_init(_model_path: &str) -> *mut LlamaContext {
        std::ptr::null_mut()
    }

    pub fn llama_generate(_ctx: *mut LlamaContext, _prompt: &str, _n: i32) -> String {
        "mock-output".into()
    }

    pub fn llama_cancel(_ctx: *mut LlamaContext) {}

    pub fn llama_free(_ctx: *mut LlamaContext) {}
}
