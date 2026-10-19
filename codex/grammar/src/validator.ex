defmodule Codex.Grammar.Validator do
  @moduledoc """
  GBNF-aware output contracts.
  Returns ValidationEvidence or ValidationError.
  Invalid output never reaches the approved channel (I5).
  """

  defstruct [:valid, :reason, :evidence]

  def validate_boolean(payload) when is_binary(payload) do
    case payload do
      "true" -> %__MODULE__{valid: true, reason: :exact_match, evidence: "boolean"}
      "false" -> %__MODULE__{valid: true, reason: :exact_match, evidence: "boolean"}
      _ -> %__MODULE__{valid: false, reason: :not_boolean, evidence: payload}
    end
  end

  def validate_enum(payload, allowed) when is_binary(payload) and is_list(allowed) do
    if payload in allowed do
      %__MODULE__{valid: true, reason: :in_set, evidence: payload}
    else
      %__MODULE__{valid: false, reason: :not_in_set, evidence: payload}
    end
  end

  def validate_command(payload) when is_binary(payload) do
    # Placeholder for sovereign command grammar
    if String.match?(payload, ~r/^(READ|WRITE|RUN|SET|ALLOC|FREE|OPEN|FIX|TEST) /) do
      %__MODULE__{valid: true, reason: :verb_match, evidence: "command"}
    else
      %__MODULE__{valid: false, reason: :bad_verb, evidence: payload}
    end
  end
end
