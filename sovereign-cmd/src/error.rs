#[derive(Debug, Clone, PartialEq)]
pub enum ParseError {
    ExpectedVerb,
    ExpectedTarget,
    ExpectedArgument,
    UnknownVerb,
    InvalidUtf8,
}
