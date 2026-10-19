#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    Verb(String),
    Identifier(String),
    FilePath(String),
    Integer(i64),
    MemoryAddress(u64),
    Flag(String),
    Newline,
}

pub struct Lexer<'a> {
    input: &'a [u8],
    cursor: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(input: &'a str) -> Self {
        Self { input: input.as_bytes(), cursor: 0 }
    }

    fn skip_ws(&mut self) {
        while self.cursor < self.input.len() {
            let b = self.input[self.cursor];
            if b == b' ' || b == b'\t' || b == b'\r' {
                self.cursor += 1;
            } else {
                break;
            }
        }
    }

    pub fn next_token(&mut self) -> Result<Option<Token>, &'static str> {
        self.skip_ws();
        if self.cursor >= self.input.len() {
            return Ok(None);
        }
        let start = self.cursor;
        let b = self.input[start];

        if b == b'\n' {
            self.cursor += 1;
            return Ok(Some(Token::Newline));
        }

        while self.cursor < self.input.len() {
            let c = self.input[self.cursor];
            if c == b' ' || c == b'\n' || c == b'\t' || c == b'\r' {
                break;
            }
            self.cursor += 1;
        }

        let slice = std::str::from_utf8(&self.input[start..self.cursor])
            .map_err(|_| "invalid utf-8")?;

        if let Some(addr) = slice.strip_prefix("0x") {
            if let Ok(n) = u64::from_str_radix(addr, 16) {
                return Ok(Some(Token::MemoryAddress(n)));
            }
        }
        if let Ok(n) = slice.parse::<i64>() {
            return Ok(Some(Token::Integer(n)));
        }
        if slice.starts_with("--") {
            return Ok(Some(Token::Flag(slice.to_string())));
        }
        if slice.starts_with('/') {
            return Ok(Some(Token::FilePath(slice.to_string())));
        }

        match slice {
            "FIX" | "OPEN" | "SET" | "TEST" | "RUN" | "READ" | "WRITE" | "ALLOC" | "FREE" => {
                Ok(Some(Token::Verb(slice.to_string())))
            }
            _ => Ok(Some(Token::Identifier(slice.to_string()))),
        }
    }

    pub fn tokenize(&mut self) -> Result<Vec<Token>, &'static str> {
        let mut out = Vec::new();
        while let Some(t) = self.next_token()? {
            out.push(t);
        }
        Ok(out)
    }
}
