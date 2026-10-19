// SnapKitty Opaque License
// Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
// Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

use sovereign_cmd::{ExecutionContract, Lexer, Parser};

fn main() {
    let input = "READ /opt/sovereign/bin/tool\nWRITE 0x2000 1\nRUN /opt/sovereign/bin/worker\n";
    let mut lexer = Lexer::new(input);
    match lexer.tokenize() {
        Ok(tokens) => {
            let mut parser = Parser::new(tokens);
            match parser.parse() {
                Ok(cmds) => {
                    for cmd in &cmds {
                        match ExecutionContract::validate(cmd) {
                            Ok(()) => println!("OK  {:?}", cmd),
                            Err(e) => println!("FAIL {:?}", e),
                        }
                    }
                }
                Err(e) => eprintln!("parse error: {:?}", e),
            }
        }
        Err(e) => eprintln!("lex error: {}", e),
    }
}
