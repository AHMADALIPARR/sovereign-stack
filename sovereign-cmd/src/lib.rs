// SnapKitty Opaque License
// Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
// Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

//! Sovereign command grammar — zero-copy lexer, parser, and execution contract.

pub mod ast;
pub mod contract;
pub mod error;
pub mod lexer;
pub mod parser;

pub use ast::{Argument, CommandAST, Target};
pub use contract::ExecutionContract;
pub use error::ParseError;
pub use lexer::{Token, Lexer};
pub use parser::Parser;
