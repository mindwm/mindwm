let URLSchema = std.contract.from_predicate(
  fun value => std.string.is_match "^([a-zA-Z]+)://(?:([a-zA-Z0-9]+)(?::([a-zA-Z0-9]+))?@)?([a-zA-Z0-9.-]+)(?::(\\d+))?(/.*)?$" value
) in
{
  UrlSchema = URLSchema
}
