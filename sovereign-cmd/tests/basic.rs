use sovereign_cmd::{ExecutionContract, Lexer, Parser, CommandAST};

#[test]
fn parse_valid_read() {
    let mut lx = Lexer::new("READ /opt/sovereign/bin/tool\n");
    let tokens = lx.tokenize().unwrap();
    let mut p = Parser::new(tokens);
    let cmds = p.parse().unwrap();
    assert_eq!(cmds.len(), 1);
    assert!(matches!(cmds[0], CommandAST::Read { .. }));
}

#[test]
fn contract_rejects_protected_write() {
    let mut lx = Lexer::new("WRITE 0x00FA 1\n");
    let tokens = lx.tokenize().unwrap();
    let mut p = Parser::new(tokens);
    let cmds = p.parse().unwrap();
    assert!(ExecutionContract::validate(&cmds[0]).is_err());
}

#[test]
fn contract_rejects_run_outside() {
    let mut lx = Lexer::new("RUN /tmp/evil\n");
    let tokens = lx.tokenize().unwrap();
    let mut p = Parser::new(tokens);
    let cmds = p.parse().unwrap();
    assert!(ExecutionContract::validate(&cmds[0]).is_err());
}
