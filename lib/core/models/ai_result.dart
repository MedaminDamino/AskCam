class AiResult {
  final bool ok;
  final String message;

  const AiResult._(this.ok, this.message);

  factory AiResult.success(String text) => AiResult._(true, text);
  factory AiResult.error(String error) => AiResult._(false, error);
}
