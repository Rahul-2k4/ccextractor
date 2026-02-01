//! Provides Rust equivalent code for functions in `utility.c` involves time operations. Uses Rust-native types as input and output.

use crate::time::units::{Timestamp, TimestampError, TimestampFormat};

/// Rust equivalent for `timestamp_to_srttime` function in C.
/// Uses Rust-native types as input and output.
pub fn timestamp_to_srttime(
    timestamp: Timestamp,
    buffer: &mut String,
) -> Result<(), TimestampError> {
    timestamp.write_srt_time(buffer)
}

/// Rust equivalent for `timestamp_to_vtttime` function in C.
/// Uses Rust-native types as input and output.
pub fn timestamp_to_vtttime(
    timestamp: Timestamp,
    buffer: &mut String,
) -> Result<(), TimestampError> {
    timestamp.write_vtt_time(buffer)
}

/// Rust equivalent for `millis_to_date` function in C. Uses Rust-native types as input and output.
pub fn millis_to_date(
    timestamp: Timestamp,
    buffer: &mut String,
    date_format: TimestampFormat,
) -> Result<(), TimestampError> {
    timestamp.write_formatted_time(buffer, date_format)
}

/// Rust equivalent for `stringztoms` function in C. Uses Rust-native types as input and output.
/// Parses both HH:MM:SS format and plain milliseconds (e.g., "5000" for 5 seconds).
pub fn stringztoms(s: &str) -> Option<Timestamp> {
    // First try HH:MM:SS format
    if let Ok(ts) = Timestamp::parse_optional_hhmmss_from_str(s) {
        return Some(ts);
    }
    
    // If that fails, try parsing as plain milliseconds
    if let Ok(millis) = s.parse::<i64>() {
        if millis >= 0 {
            return Some(Timestamp::from_millis(millis));
        }
    }
    
    None
}
