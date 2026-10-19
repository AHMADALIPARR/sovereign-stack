use crate::ast::{CommandAST, Target};
use std::path::Path;

pub struct ExecutionContract;

impl ExecutionContract {
    pub fn validate(ast: &CommandAST) -> Result<(), &'static str> {
        match ast {
            CommandAST::Write { target: Target::MemoryAddress(addr), .. } => {
                if *addr < 0x1000 {
                    return Err("CONTRACT VIOLATION: Attempted write to protected memory space.");
                }
                Ok(())
            }
            CommandAST::Run { target: Target::FilePath(path), .. } => {
                if !path.starts_with("/opt/sovereign/bin/") {
                    return Err("CONTRACT VIOLATION: Execution outside of permitted binary directory.");
                }
                if path.as_os_str().is_empty() || Path::new(path).file_name().is_none() {
                    return Err("CONTRACT VIOLATION: RUN target must be a file.");
                }
                Ok(())
            }
            CommandAST::Run { target: Target::Identifier(_), .. } => {
                Err("CONTRACT VIOLATION: RUN requires a path under /opt/sovereign/bin/.")
            }
            _ => Ok(()),
        }
    }
}
