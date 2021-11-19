//**************************************************************************************************
// BitmapFontInfo.bf                                                                               *
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
    public sealed class BitmapFontInfo
    {
        public const int32 MinSizeInBytes = 15;

        public int32 Size { get; set; }

        public bool Smooth { get; set; }
        public bool Unicode { get; set; }
        public bool Italic { get; set; }
        public bool Bold { get; set; }

		private String charset = new .() ~ delete _;
        public StringView Charset
		{
			get => charset;
			set => charset.Set(value);
		}

        public int32 StretchHeight { get; set; }
        public int32 SuperSamplingLevel { get; set; }

        public int32 PaddingUp { get; set; }
        public int32 PaddingRight { get; set; }
        public int32 PaddingDown { get; set; }
        public int32 PaddingLeft { get; set; }

        public int32 SpacingHorizontal { get; set; }
        public int32 SpacingVertical { get; set; }

        public int32 Outline { get; set; }

		private String face = new .() ~ delete _;
        public StringView Face
		{
			get => face;
			set => face.Set(value);
		}

        public Result<void> WriteBinary(Stream stream)
        {
            Try!(stream.Write(MinSizeInBytes + (int32)Face.Length));
            Try!(stream.Write((int16)Size));

            uint8 bitField = 0;

            bitField = bitField.SetBit(7, Smooth);
            bitField = bitField.SetBit(6, Unicode);
            bitField = bitField.SetBit(5, Italic);
            bitField = bitField.SetBit(4, Bold);

            Try!(stream.Write(bitField));

            uint8 characterSetID = 0;

            if (!Charset.IsEmpty)
            {
                characterSetID = (uint8)Try!(Enum.Parse<CharacterSet>(Charset, true));
            }

            Try!(stream.Write(characterSetID));

            Try!(stream.Write((uint16)StretchHeight));
            Try!(stream.Write((uint8)SuperSamplingLevel));

            Try!(stream.Write((uint8)PaddingUp));
            Try!(stream.Write((uint8)PaddingRight));
            Try!(stream.Write((uint8)PaddingDown));
            Try!(stream.Write((uint8)PaddingLeft));

            Try!(stream.Write((uint8)SpacingHorizontal));
            Try!(stream.Write((uint8)SpacingVertical));

            Try!(stream.Write((uint8)Outline));
            Try!(stream.WriteNullTerminatedString(Face));

			return .Ok;
        }

        public void WriteXML(XmlNode element) 
        {
            element.SetAttribute("face", Face);
            element.SetAttribute("size", Size); 
            element.SetAttribute("bold", (int32)Bold);
            element.SetAttribute("italic", (int32)Italic);

            element.SetAttribute("charset", Charset);

            element.SetAttribute("unicode", (int32)Unicode);
            element.SetAttribute("stretchH", StretchHeight);
            element.SetAttribute("smooth",(int32)Smooth);
            element.SetAttribute("aa", SuperSamplingLevel);

            let padding = scope $"{PaddingUp},{PaddingRight},{PaddingDown},{PaddingLeft}";
            element.SetAttribute("padding", padding);

            let spacing = scope $"{SpacingHorizontal},{SpacingVertical}";
            element.SetAttribute("spacing", spacing);

            element.SetAttribute("outline", Outline);
        }

        public Result<void> WriteText(StreamWriter textWriter) 
        {
            Try!(TextFormatUtility.WriteString("face", Face, textWriter));
            Try!(TextFormatUtility.WriteInt("size", Size, textWriter));
            Try!(TextFormatUtility.WriteBool("bold", Bold, textWriter));
            Try!(TextFormatUtility.WriteBool("italic", Italic, textWriter));

            Try!(TextFormatUtility.WriteString("charset", Charset, textWriter));

            Try!(TextFormatUtility.WriteBool("unicode", Unicode, textWriter));
            Try!(TextFormatUtility.WriteInt("stretchH", StretchHeight, textWriter));
            Try!(TextFormatUtility.WriteBool("smooth", Smooth, textWriter));
            Try!(TextFormatUtility.WriteInt("aa", SuperSamplingLevel, textWriter));

            let padding = scope $"{PaddingUp},{PaddingRight},{PaddingDown},{PaddingLeft}";
            Try!(TextFormatUtility.WriteValue("padding", padding, textWriter));

            let spacing = scope $"{SpacingHorizontal},{SpacingVertical}";
            Try!(TextFormatUtility.WriteValue("spacing", spacing, textWriter));

            Try!(TextFormatUtility.WriteInt("outline", Outline, textWriter));
			return .Ok;
        }

        public static Result<BitmapFontInfo> ReadBinary(Stream stream)
        {
            if (Try!(stream.Read<int32>()) < MinSizeInBytes)
            {
                return .Err; // Invalid info block size.
            }

            let bitmapFontInfo = new BitmapFontInfo();
            bitmapFontInfo.Size = Try!(stream.Read<int16>());

            let bitField = Try!(stream.Read<uint8>());
            bitmapFontInfo.Smooth = bitField.IsBitSet(7);
            bitmapFontInfo.Unicode = bitField.IsBitSet(6);
            bitmapFontInfo.Italic = bitField.IsBitSet(5);
            bitmapFontInfo.Bold = bitField.IsBitSet(4);

            let characterSet = (CharacterSet)Try!(stream.Read<uint8>());
            bitmapFontInfo.Charset = characterSet.ToString(.. scope .())..ToUpper();

            bitmapFontInfo.StretchHeight = Try!(stream.Read<uint16>());
            bitmapFontInfo.SuperSamplingLevel = Try!(stream.Read<uint8>());

            bitmapFontInfo.PaddingUp = Try!(stream.Read<uint8>());
            bitmapFontInfo.PaddingRight = Try!(stream.Read<uint8>());
            bitmapFontInfo.PaddingDown = Try!(stream.Read<uint8>());
            bitmapFontInfo.PaddingLeft = Try!(stream.Read<uint8>());

            bitmapFontInfo.SpacingHorizontal = Try!(stream.Read<uint8>());
            bitmapFontInfo.SpacingVertical = Try!(stream.Read<uint8>());

            bitmapFontInfo.Outline = Try!(stream.Read<uint8>());
            Try!(stream.ReadNullTerminatedString(bitmapFontInfo.face));

            return bitmapFontInfo;
        }

        public static BitmapFontInfo ReadXML(XmlNode element)
        {
            let bitmapFontInfo = new BitmapFontInfo();

            bitmapFontInfo.Face = element.AttributeList.GetValueOrDefault<String>("face") ?? String.Empty;
            bitmapFontInfo.Size = element.AttributeList.GetValueOrDefault<int32>("size");
            bitmapFontInfo.Bold = element.AttributeList.GetValueOrDefault<bool>("bold");
            bitmapFontInfo.Italic = element.AttributeList.GetValueOrDefault<bool>("italic");

            bitmapFontInfo.Charset = element.AttributeList.GetValueOrDefault<String>("charset") ?? String.Empty;

            bitmapFontInfo.Unicode = element.AttributeList.GetValueOrDefault<bool>("unicode");
            bitmapFontInfo.StretchHeight = element.AttributeList.GetValueOrDefault<int32>("stretchH");
            bitmapFontInfo.Smooth = element.AttributeList.GetValueOrDefault<bool>("smooth");
            bitmapFontInfo.SuperSamplingLevel = element.AttributeList.GetValueOrDefault<int32>("aa");
            
            var padding = (element.AttributeList.GetValueOrDefault<String>("padding"))?.Split(',');
            if (padding?.HasMore == true)
            {
                bitmapFontInfo.PaddingUp = int32.Parse(padding.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingRight = int32.Parse(padding.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingDown = int32.Parse(padding.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingLeft = int32.Parse(padding.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
            }

            var spacing = (element.AttributeList.GetValueOrDefault<String>("spacing"))?.Split(',');
            if (spacing?.HasMore == true)
            {
                bitmapFontInfo.SpacingHorizontal = int32.Parse(spacing.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.SpacingVertical = int32.Parse(spacing.ValueRef.GetNext().GetValueOrDefault()).GetValueOrDefault();
            }

            bitmapFontInfo.Outline = element.AttributeList.GetValueOrDefault<int32>("outline");

            return bitmapFontInfo;
        }

        public static Result<BitmapFontInfo> ReadText(List<StringView> lineSegments) 
        {
            let bitmapFontInfo = new BitmapFontInfo();

            bitmapFontInfo.Face = TextFormatUtility.ReadString("face", lineSegments, String.Empty);
            bitmapFontInfo.Size = Try!(TextFormatUtility.ReadInt("size", lineSegments));
            bitmapFontInfo.Bold = Try!(TextFormatUtility.ReadBool("bold", lineSegments));
            bitmapFontInfo.Italic = Try!(TextFormatUtility.ReadBool("italic", lineSegments));

            bitmapFontInfo.Charset = TextFormatUtility.ReadString("charset", lineSegments, String.Empty);

            bitmapFontInfo.Unicode = Try!(TextFormatUtility.ReadBool("unicode", lineSegments));
            bitmapFontInfo.StretchHeight = Try!(TextFormatUtility.ReadInt("stretchH", lineSegments));
            bitmapFontInfo.Smooth = Try!(TextFormatUtility.ReadBool("smooth", lineSegments));
            bitmapFontInfo.SuperSamplingLevel = Try!(TextFormatUtility.ReadInt("aa", lineSegments));

            var padding = TextFormatUtility.ReadValue("padding", lineSegments).Split(',');
            if (padding.HasMore)
            {
                bitmapFontInfo.PaddingUp = int32.Parse(padding.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingRight = int32.Parse(padding.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingDown = int32.Parse(padding.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.PaddingLeft = int32.Parse(padding.GetNext().GetValueOrDefault()).GetValueOrDefault();
            }

            var spacing = TextFormatUtility.ReadValue("spacing", lineSegments).Split(',');
            if (spacing.HasMore)
            {
                bitmapFontInfo.SpacingHorizontal = int32.Parse(spacing.GetNext().GetValueOrDefault()).GetValueOrDefault();
                bitmapFontInfo.SpacingVertical = int32.Parse(spacing.GetNext().GetValueOrDefault()).GetValueOrDefault();
            }

            bitmapFontInfo.Outline = Try!(TextFormatUtility.ReadInt("outline", lineSegments));

            return bitmapFontInfo;
        }
    }
}