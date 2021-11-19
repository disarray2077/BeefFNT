//**************************************************************************************************
// KerningPair.bf                                                                                  *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.Collections;
using System.IO;
using Xml_Beef;

using internal BeefFNT;

namespace BeefFNT
{
    public struct KerningPair : IEquatable<KerningPair>, IHashable
    {
        public const int32 SizeInBytes = 10;

        public int32 First { get; }

        public int32 Second { get; }

        public this(int32 first, int32 second)
        {
            First = first;
            Second = second;
        }

        public Result<void> WriteBinary(Stream stream, int32 amount)
        {
            Try!(stream.Write((uint32)First));
            Try!(stream.Write((uint32)Second));
            Try!(stream.Write((int16)amount));
			return .Ok;
        }

        public void WriteXML(XmlNode element, int32 amount) 
        {
            element.SetAttribute("first", First);
            element.SetAttribute("second", Second);
            element.SetAttribute("amount", amount);
        }

        public Result<void> WriteText(StreamWriter textWriter, int32 amount)
        {
            Try!(TextFormatUtility.WriteInt("first", First, textWriter));
            Try!(TextFormatUtility.WriteInt("second", Second, textWriter));
            Try!(TextFormatUtility.WriteInt("amount", amount, textWriter));
			return .Ok;
        }

        public bool Equals(KerningPair other)
        {
            return First == other.First && Second == other.Second;
        }

		[Unchecked]
        public int GetHashCode()
        {
            return (First.GetHashCode() * 397) ^ Second.GetHashCode();
        }

        public static bool operator ==(KerningPair left, KerningPair right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(KerningPair left, KerningPair right)
        {
            return !left.Equals(right);
        }

        public override void ToString(String outString)
        {
            outString.AppendF($"First: {First}, Second: {Second}");
        }

        public static Result<KerningPair> ReadBinary(Stream stream, out int32 amount)
        {
			amount = ?;
            let first = (int32)Try!(stream.Read<uint32>());
            let second = (int32)Try!(stream.Read<uint32>());
            amount = (int32)Try!(stream.Read<int16>());

            return KerningPair(first, second);
        }

        public static KerningPair ReadXML(XmlNode element, out int32 amount)
        {
            let first = element.AttributeList.GetValueOrDefault<int32>("first");
            let second = element.AttributeList.GetValueOrDefault<int32>("second");
            amount = element.AttributeList.GetValueOrDefault<int32>("amount");

            return KerningPair(first, second); 
        }

        public static Result<KerningPair> ReadText(List<StringView> lineSegments, out int32 amount)
        {
			amount = ?;
            let first = Try!(TextFormatUtility.ReadInt("first", lineSegments));
            let second = Try!(TextFormatUtility.ReadInt("second", lineSegments));
            amount = Try!(TextFormatUtility.ReadInt("amount", lineSegments));

            return KerningPair(first, second);
        }
    }
}