class_name TimeFormatter
extends RefCounted

## Enum for the available output formats.
enum Format {
	CLOCK,          # e.g. "10:20:24" or "10:20"
	LITERAL_LONG,   # e.g. "10 hours, 20 minutes, 24 seconds"
	LITERAL_SHORT,  # e.g. "10 hrs, 20 mins, 24 secs"
}

## Converts a number of seconds into a formatted duration string.
##
## total_seconds:    the duration to format (float or int, seconds)
## format:           Format.CLOCK, Format.LITERAL_LONG, or Format.LITERAL_SHORT
## separator:        string placed between components
##                   (ignored for CLOCK unless you want a custom clock separator)
## include_seconds:  if false, seconds are dropped from the output entirely
static func format_duration(
	total_seconds: float,
	format: Format = Format.CLOCK,
	separator: String = ", ",
	include_seconds: bool = true
) -> String:
	var secs_int: int = int(round(total_seconds))
	if secs_int < 0:
		secs_int = 0

	var hours: int = secs_int / 3600
	var minutes: int = (secs_int % 3600) / 60
	var seconds: int = secs_int % 60

	match format:
		Format.CLOCK:
			return _format_clock(hours, minutes, seconds, separator, include_seconds)
		Format.LITERAL_LONG:
			return _format_literal(hours, minutes, seconds, separator, include_seconds, false)
		Format.LITERAL_SHORT:
			return _format_literal(hours, minutes, seconds, separator, include_seconds, true)
		_:
			push_warning("TimeFormatter: unknown format, defaulting to CLOCK")
			return _format_clock(hours, minutes, seconds, separator, include_seconds)


static func _format_clock(hours: int, minutes: int, seconds: int, separator: String, include_seconds: bool) -> String:
	# Default clock separator is ":" if caller didn't override it.
	var sep: String = separator if separator != "" else ":"

	var parts: Array[String] = []
	parts.append("%02d" % hours)
	parts.append("%02d" % minutes)
	if include_seconds:
		parts.append("%02d" % seconds)

	return sep.join(parts)


static func _format_literal(hours: int, minutes: int, seconds: int, separator: String, include_seconds: bool, short: bool) -> String:
	var parts: Array[String] = []

	if hours > 0:
		parts.append(_unit_string(hours, "hour", "hr", short))
	if minutes > 0 or hours > 0:
		parts.append(_unit_string(minutes, "minute", "min", short))
	if include_seconds:
		# Always show seconds if it's the only unit present (e.g. "24 seconds"),
		# or if there's a nonzero value to report.
		if seconds > 0 or parts.is_empty():
			parts.append(_unit_string(seconds, "second", "sec", short))

	if parts.is_empty():
		# Nothing to show at all (e.g. 0 seconds, include_seconds = false)
		parts.append(_unit_string(0, "minute", "min", short))

	return separator.join(parts)


static func _unit_string(value: int, long_singular: String, short_singular: String, short: bool) -> String:
	if short:
		return "%d %ss" % [value, short_singular]
	else:
		var word: String = long_singular if value == 1 else long_singular + "s"
		return "%d %s" % [value, word]
