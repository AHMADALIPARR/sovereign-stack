//! Sovereign command grammar — zero-copy lexer, parser, and execution contract.
//! AGPL-3.0-only

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
