# SnapKitty Opaque License
# Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust / SnapKitty Collective Limited
# Sealed core. See SNAPKITTY_OPAQUE_LICENSE.md

defmodule Codex.Grammar.Validator do
  @moduledoc """
  Deterministic contracts. Invalid output never enters approved channel (I5).
  """

  defstruct [:valid, :reason, :evidence]

  def validate_boolean("true"), do: ok("boolean")
  def validate_boolean("false"), do: ok("boolean")
  def validate_boolean(other), do: reject(:not_boolean, other)

  def validate_enum(payload, allowed) when is_list(allowed) do
    if payload in allowed, do: ok(payload), else: reject(:not_in_set, payload)
  end

  def validate_command(payload) when is_binary(payload) do
    if String.match?(payload, ~r/^(READ|WRITE|RUN|SET|ALLOC|FREE|OPEN|FIX|TEST) /) do
      ok("command")
    else
      reject(:bad_verb, payload)
    end
  end

  defp ok(e), do: %__MODULE__{valid: true, reason: :ok, evidence: e}
  defp reject(r, e), do: %__MODULE__{valid: false, reason: r, evidence: e}
end
