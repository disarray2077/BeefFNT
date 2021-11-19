//**************************************************************************************************
// TextFormatUtility.bf                                                                            *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.Collections;
using System.IO;
using System.Text;

using internal BeefFNT;

namespace BeefFNT
{
    public static class TextFormatUtility
    {
        public static void GetSegments(String line, List<StringView> segments)
        {
			segments.Reserve(16);
            var ignoreWhiteSpace = false;
			var startIdx = 0;

            for (var i = 0; i < line.Length; i++)
            {
                let character = line[i];

                let endSegment = character == ' ' && !ignoreWhiteSpace;

                if (!endSegment && character == '\"')
                {
                    ignoreWhiteSpace = !ignoreWhiteSpace;
                }

				let endOfLine = i == line.Length - 1;

                if ((endSegment || endOfLine) && i != startIdx)
                {
                    segments.Add(line.Substring(startIdx, i - startIdx + (int)endOfLine));
                    startIdx = i + 1;
                }
            }
        }

        public static StringView ReadValue(String propertyName, List<StringView> segments)
        {
            for (let segment in segments)
            {
                let equalsSign = segment.IndexOf('=');

                if (equalsSign != propertyName.Length) continue;

                if (propertyName.Equals(segment.Substring(0, equalsSign), true))
                {
					var value = segment.Substring(equalsSign + 1);

					if (value[0] == '\"' && value[value.Length - 1] == '\"')
					{
						value.Adjust(1);
						value.RemoveFromEnd(1);
					}

                    return value;
                }
            }

            return default;
        }

        public static Result<bool> ReadBool(String propertyName, List<StringView> segments, bool missingValue = false) 
        {
            let value = ReadValue(propertyName, segments);

            switch (value)
            {
                case when value.Ptr == null:
                    return missingValue;
                case "1":
                    return true;
                case "0":
                    return false;
                // True and false aren't valid but might as well try to use them anyway.
				case when value.Equals("True", true):
					return true;
				case when value.Equals("False", true):
					return false;
                default:
                    return .Err;
            }
        }

        public static Result<int32> ReadInt(String propertyName, List<StringView> segments, int32 missingValue = 0) 
        {
            let value = ReadValue(propertyName, segments);
            return value.Ptr != null ? Try!(int32.Parse(value)) : missingValue;
        }

        public static StringView ReadString(String propertyName, List<StringView> segments, StringView missingValue = default)
        {
			let value = ReadValue(propertyName, segments);
            return value.Ptr != null ? value : missingValue;
        }

        public static Result<T> ReadEnum<T>(String propertyName, List<StringView> segments, T missingValue = default) where T : Enum
        {
            let value = ReadValue(propertyName, segments);
            return value.Ptr != null ? (T)Try!(int32.Parse(value)) : missingValue;
        }

        public static Result<void> WriteValue(String propertyName, String value, StreamWriter textWriter)
        {
            return textWriter.Write(" {0}={1}", propertyName, value);
        }

        public static Result<void> WriteString(String propertyName, String value, StreamWriter textWriter) 
        {
            return textWriter.Write(" {0}=\"{1}\"", propertyName, value);
        }

        public static Result<void> WriteString(String propertyName, StringView value, StreamWriter textWriter) 
        {
            return textWriter.Write(" {0}=\"{1}\"", propertyName, value);
        }

        public static Result<void> WriteInt(String propertyName, int32 value, StreamWriter textWriter) 
        {
            return WriteValue(propertyName, value.ToString(.. scope .()), textWriter);
        }

        public static Result<void> WriteBool(String propertyName, bool value, StreamWriter textWriter) 
        {
            return WriteValue(propertyName, value ? "1" : "0", textWriter);
        }

        public static Result<void> WriteEnum<T>(String propertyName, T value, StreamWriter textWriter) where T : Enum
        {
            return WriteInt(propertyName, (int32)value, textWriter);
        }
    }
}