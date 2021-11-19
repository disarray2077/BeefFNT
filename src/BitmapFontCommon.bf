//**************************************************************************************************
// BitmapFontCommon.bf                                                                             *
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
    public sealed class BitmapFontCommon
    {
        public const int32 SizeInBytes = 15;

        public int32 LineHeight { get; set; }

        public int32 Base { get; set; }

        public int32 ScaleWidth { get; set; }

        public int32 ScaleHeight { get; set; }

        public bool Packed { get; set; }

        public ChannelData AlphaChannel { get; set; }

        public ChannelData RedChannel { get; set; }

        public ChannelData GreenChannel { get; set; }

        public ChannelData BlueChannel { get; set; }

        public Result<void> WriteBinary(Stream stream, int32 pages)
        {
            Try!(stream.Write(SizeInBytes));
            Try!(stream.Write((uint16)LineHeight));
            Try!(stream.Write((uint16)Base));
            Try!(stream.Write((uint16)ScaleWidth));
            Try!(stream.Write((uint16)ScaleHeight));
            Try!(stream.Write((uint16)pages));

            uint8 packed = 0;
            packed = packed.SetBit(0, Packed);
            Try!(stream.Write(packed));

            Try!(stream.Write((uint8)AlphaChannel));
            Try!(stream.Write((uint8)RedChannel));
            Try!(stream.Write((uint8)GreenChannel));
            Try!(stream.Write((uint8)BlueChannel));
			return .Ok;
        }

        public void WriteXML(XmlNode element, int pages) 
        {
            element.SetAttribute("lineHeight", LineHeight);
            element.SetAttribute("base", Base);
            element.SetAttribute("scaleW", ScaleWidth);
            element.SetAttribute("scaleH", ScaleHeight);

            element.SetAttribute("pages", pages);

            element.SetAttribute("packed", (int32)Packed);

            element.SetAttribute("alphaChnl", (int32)AlphaChannel);
            element.SetAttribute("redChnl", (int32)RedChannel);
            element.SetAttribute("greenChnl", (int32)GreenChannel);
            element.SetAttribute("blueChnl", (int32)BlueChannel);
        }

        public Result<void> WriteText(StreamWriter textWriter, int32 pages)
        {
            Try!(TextFormatUtility.WriteInt("lineHeight", LineHeight, textWriter));
            Try!(TextFormatUtility.WriteInt("base", Base, textWriter));
            Try!(TextFormatUtility.WriteInt("scaleW", ScaleWidth, textWriter));
            Try!(TextFormatUtility.WriteInt("scaleH", ScaleHeight, textWriter));

            Try!(TextFormatUtility.WriteInt("pages", pages, textWriter));

            Try!(TextFormatUtility.WriteBool("packed", Packed, textWriter));

            Try!(TextFormatUtility.WriteEnum("alphaChnl", AlphaChannel, textWriter));
            Try!(TextFormatUtility.WriteEnum("redChnl", RedChannel, textWriter));
            Try!(TextFormatUtility.WriteEnum("greenChnl", GreenChannel, textWriter));
            Try!(TextFormatUtility.WriteEnum("blueChnl", BlueChannel, textWriter));
			return .Ok;
        }

        public static Result<BitmapFontCommon> ReadBinary(Stream stream, out int32 pageCount)
        {
			pageCount = ?;

            if (Try!(stream.Read<int32>()) != SizeInBytes)
            {
                return .Err; // Invalid common block size.
            }

            let binary = new BitmapFontCommon();

			defer
			{
				if (@return case .Err)
					delete binary;
			}

            binary.LineHeight = Try!(stream.Read<uint16>());
            binary.Base = Try!(stream.Read<uint16>());
            binary.ScaleWidth = Try!(stream.Read<uint16>());
            binary.ScaleHeight = Try!(stream.Read<uint16>());

            pageCount = Try!(stream.Read<uint16>());

            binary.Packed = Try!(stream.Read<uint8>()).IsBitSet(0);
            binary.AlphaChannel = (ChannelData)Try!(stream.Read<uint8>());
            binary.RedChannel = (ChannelData)Try!(stream.Read<uint8>());
            binary.GreenChannel = (ChannelData)Try!(stream.Read<uint8>());
            binary.BlueChannel = (ChannelData)Try!(stream.Read<uint8>());

            return binary;
        }

        public static BitmapFontCommon ReadXML(XmlNode element, out int32 pages) 
        {
            let bitmapFontCommon = new BitmapFontCommon();

            bitmapFontCommon.LineHeight = element.AttributeList.GetValueOrDefault<int32>("lineHeight");
            bitmapFontCommon.Base = element.AttributeList.GetValueOrDefault<int32>("base");
            bitmapFontCommon.ScaleWidth = element.AttributeList.GetValueOrDefault<int32>("scaleW");
            bitmapFontCommon.ScaleHeight = element.AttributeList.GetValueOrDefault<int32>("scaleH");

            pages = element.AttributeList.GetValueOrDefault<int32>("pages");

            bitmapFontCommon.Packed = element.AttributeList.GetValueOrDefault<bool>("packed");
            
            bitmapFontCommon.AlphaChannel = element.AttributeList.GetValueOrDefault<ChannelData>("alphaChnl");
            bitmapFontCommon.RedChannel = element.AttributeList.GetValueOrDefault<ChannelData>("redChnl");
            bitmapFontCommon.GreenChannel = element.AttributeList.GetValueOrDefault<ChannelData>("greenChnl");
            bitmapFontCommon.BlueChannel = element.AttributeList.GetValueOrDefault<ChannelData>("blueChnl");

            return bitmapFontCommon;
        }

        public static Result<BitmapFontCommon> ReadText(List<StringView> lineSegments, out int32 pages) 
        {
			pages = ?;

            let bitmapFontCommon = new BitmapFontCommon();

			defer
			{
				if (@return case .Err)
					delete bitmapFontCommon;
			}

            bitmapFontCommon.LineHeight = Try!(TextFormatUtility.ReadInt("lineHeight", lineSegments));
            bitmapFontCommon.Base = Try!(TextFormatUtility.ReadInt("base", lineSegments));
            bitmapFontCommon.ScaleWidth = Try!(TextFormatUtility.ReadInt("scaleW", lineSegments));
            bitmapFontCommon.ScaleHeight = Try!(TextFormatUtility.ReadInt("scaleH", lineSegments));

            pages = Try!(TextFormatUtility.ReadInt("pages", lineSegments));

            bitmapFontCommon.Packed = Try!(TextFormatUtility.ReadBool("packed", lineSegments));
            
            bitmapFontCommon.AlphaChannel = Try!(TextFormatUtility.ReadEnum<ChannelData>("alphaChnl", lineSegments));
            bitmapFontCommon.RedChannel = Try!(TextFormatUtility.ReadEnum<ChannelData>("redChnl", lineSegments));
            bitmapFontCommon.GreenChannel = Try!(TextFormatUtility.ReadEnum<ChannelData>("greenChnl", lineSegments));
            bitmapFontCommon.BlueChannel = Try!(TextFormatUtility.ReadEnum<ChannelData>("blueChnl", lineSegments));

            return bitmapFontCommon;
        }
    }
}