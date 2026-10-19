use crate::ast::{Argument, CommandAST, Target};
use crate::error::ParseError;
use crate::lexer::Token;

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }

    fn peek(&self) -> Option<&Token> {
        self.tokens.get(self.pos)
    }

    fn bump(&mut self) -> Option<Token> {
        let t = self.tokens.get(self.pos).cloned();
        if t.is_some() {
            self.pos += 1;
        }
        t
    }

    pub fn parse(&mut self) -> Result<Vec<CommandAST>, ParseError> {
        let mut cmds = Vec::new();
        while self.pos < self.tokens.len() {
            if matches!(self.peek(), Some(Token::Newline)) {
                self.bump();
                continue;
            }
            cmds.push(self.parse_command()?);
        }
        Ok(cmds)
    }

    fn parse_command(&mut self) -> Result<CommandAST, ParseError> {
        let verb = match self.bump() {
            Some(Token::Verb(v)) => v,
            _ => return Err(ParseError::ExpectedVerb),
        };

        let target = self.parse_target()?;
        let mut args = Vec::new();
        while let Some(t) = self.peek() {
            if matches!(t, Token::Newline) {
                break;
            }
            args.push(self.parse_arg()?);
        }
        if matches!(self.peek(), Some(Token::Newline)) {
            self.bump();
        }

        let cmd = match verb.as_str() {
            "READ" => CommandAST::Read { target, args },
            "WRITE" => CommandAST::Write { target, args },
            "RUN" => CommandAST::Run { target, args },
            "SET" => CommandAST::Set { target, args },
            "ALLOC" => CommandAST::Alloc { target, args },
            "FREE" => CommandAST::Free { target, args },
            "OPEN" => CommandAST::Open { target, args },
            "FIX" => CommandAST::Fix { target, args },
            "TEST" => CommandAST::Test { target, args },
            _ => return Err(ParseError::UnknownVerb),
        };
        Ok(cmd)
    }

    fn parse_target(&mut self) -> Result<Target, ParseError> {
        match self.bump() {
            Some(Token::Identifier(s)) => Ok(Target::Identifier(s)),
            Some(Token::FilePath(s)) => Ok(Target::FilePath(s.into())),
            Some(Token::MemoryAddress(n)) => Ok(Target::MemoryAddress(n)),
            _ => Err(ParseError::ExpectedTarget),
        }
    }

    fn parse_arg(&mut self) -> Result<Argument, ParseError> {
        match self.bump() {
            Some(Token::Flag(s)) => Ok(Argument::Flag(s)),
            Some(Token::Identifier(s)) => Ok(Argument::Identifier(s)),
            Some(Token::Integer(n)) => Ok(Argument::Integer(n)),
            Some(Token::MemoryAddress(n)) => Ok(Argument::MemoryAddress(n)),
            _ => Err(ParseError::ExpectedArgument),
        }
    }
}
