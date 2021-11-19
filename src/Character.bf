//**************************************************************************************************
// Character.bf                                                                                    *
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
    public sealed class Character
    {
        public const int32 SizeInBytes = 20;

        public int32 X { get; set; }

        public int32 Y { get; set; }

        public int32 Width { get; set; }

        public int32 Height { get; set; }

        public int32 XOffset { get; set; }

        public int32 YOffset { get; set; }

        public int32 XAdvance { get; set; }

        public int32 Page { get; set; }

        public Channel Channel { get; set; }

        public Result<void> WriteBinary(Stream stream, int32 id) 
        {
            Try!(stream.Write((uint32)id));
            Try!(stream.Write((uint16)X));
            Try!(stream.Write((uint16)Y));
            Try!(stream.Write((uint16)Width));
            Try!(stream.Write((uint16)Height));
            Try!(stream.Write((int16)XOffset));
            Try!(stream.Write((int16)YOffset));
            Try!(stream.Write((int16)XAdvance));
            Try!(stream.Write((uint8)Page));
            Try!(stream.Write((uint8)Channel));
			return .Ok;
        }

        public void WriteXML(XmlNode element, int32 id) 
        {
            element.SetAttribute("id", id);
            element.SetAttribute("x", X);
            element.SetAttribute("y", Y);
            element.SetAttribute("width", Width);
            element.SetAttribute("height", Height);
            element.SetAttribute("xoffset", XOffset);
            element.SetAttribute("yoffset", YOffset);
            element.SetAttribute("xadvance", XAdvance);
            element.SetAttribute("page", Page);
            element.SetAttribute("chnl", (int32)Channel);
        }

        public Result<void> WriteText(StreamWriter textWriter, int32 id)
        {
            Try!(TextFormatUtility.WriteInt("id", id, textWriter));
            Try!(TextFormatUtility.WriteInt("x", X, textWriter));
            Try!(TextFormatUtility.WriteInt("y", Y, textWriter));
            Try!(TextFormatUtility.WriteInt("width", Width, textWriter));
            Try!(TextFormatUtility.WriteInt("height", Height, textWriter));
            Try!(TextFormatUtility.WriteInt("xoffset", XOffset, textWriter));
            Try!(TextFormatUtility.WriteInt("yoffset", YOffset, textWriter));
            Try!(TextFormatUtility.WriteInt("xadvance", XAdvance, textWriter));
            Try!(TextFormatUtility.WriteInt("page", Page, textWriter));
            Try!(TextFormatUtility.WriteEnum("chnl", Channel, textWriter));
			return .Ok;
        }

        public static Result<Character> ReadBinary(Stream stream, out int32 id)
        {
			id = ?;
            id = (int32)Try!(stream.Read<uint32>());

            return new Character()
            {
                X = Try!(stream.Read<uint16>()),
                Y = Try!(stream.Read<uint16>()),
                Width = Try!(stream.Read<uint16>()),
                Height = Try!(stream.Read<uint16>()),
                XOffset = Try!(stream.Read<int16>()),
                YOffset = Try!(stream.Read<int16>()),
                XAdvance = Try!(stream.Read<int16>()),
                Page = Try!(stream.Read<uint8>()),
                Channel = (Channel) Try!(stream.Read<uint8>())
            };
        }

        public static Character ReadXML(XmlNode element, out int32 id)
        {
            id = element.AttributeList.GetValueOrDefault<int32>("id");

            return new Character()
            {
                X = element.AttributeList.GetValueOrDefault<int32>("x"),
                Y = element.AttributeList.GetValueOrDefault<int32>("y"),
                Width = element.AttributeList.GetValueOrDefault<int32>("width"),
                Height = element.AttributeList.GetValueOrDefault<int32>("height"),
                XOffset = element.AttributeList.GetValueOrDefault<int32>("xoffset"),
                YOffset = element.AttributeList.GetValueOrDefault<int32>("yoffset"),
                XAdvance = element.AttributeList.GetValueOrDefault<int32>("xadvance"),
                Page = element.AttributeList.GetValueOrDefault<int32>("page"),
                Channel = element.AttributeList.GetValueOrDefault<Channel>("chnl")
            };
        }

        public static Result<Character> ReadText(List<StringView> lineSegments, out int32 id)
        {
			id = ?;
            id = Try!(TextFormatUtility.ReadInt("id", lineSegments));

            return new Character()
            {
                X = Try!(TextFormatUtility.ReadInt("x", lineSegments)),
                Y = Try!(TextFormatUtility.ReadInt("y", lineSegments)),
                Width = Try!(TextFormatUtility.ReadInt("width", lineSegments)),
                Height = Try!(TextFormatUtility.ReadInt("height", lineSegments)),
                XOffset = Try!(TextFormatUtility.ReadInt("xoffset", lineSegments)),
                YOffset = Try!(TextFormatUtility.ReadInt("yoffset", lineSegments)),
                XAdvance = Try!(TextFormatUtility.ReadInt("xadvance", lineSegments)),
                Page = Try!(TextFormatUtility.ReadInt("page", lineSegments)),
                Channel = Try!(TextFormatUtility.ReadEnum<Channel>("chnl", lineSegments))
            };
        }
    }
}