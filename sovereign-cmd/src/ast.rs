use std::path::PathBuf;

#[derive(Debug, Clone, PartialEq)]
pub enum CommandAST {
    Read { target: Target, args: Vec<Argument> },
    Write { target: Target, args: Vec<Argument> },
    Run { target: Target, args: Vec<Argument> },
    Set { target: Target, args: Vec<Argument> },
    Alloc { target: Target, args: Vec<Argument> },
    Free { target: Target, args: Vec<Argument> },
    Open { target: Target, args: Vec<Argument> },
    Fix { target: Target, args: Vec<Argument> },
    Test { target: Target, args: Vec<Argument> },
}

#[derive(Debug, Clone, PartialEq)]
pub enum Target {
    Identifier(String),
    FilePath(PathBuf),
    MemoryAddress(u64),
}

#[derive(Debug, Clone, PartialEq)]
pub enum Argument {
    Flag(String),
    Identifier(String),
    Integer(i64),
    MemoryAddress(u64),
}
