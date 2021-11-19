//**************************************************************************************************
// BitmapFont.bf                                                                                   *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.Collections;
using System.IO;
using System.Text;
using Xml_Beef;

using internal BeefFNT;

namespace BeefFNT
{
    public sealed class BitmapFont
    {
		public enum SaveError
		{
			case FileOpenFailed(FileOpenError err);
			case UnknownFormat;
			case NonConsecutivePageID;
			case SerializeError;
		}

		public enum ReadError
		{
			case FileOpenFailed(FileOpenError err);
			case UnknownFormat;
			case InvalidHeader;
			case UnsupportedVersion;
			case InvalidCharBlockSize;
			case InvalidKerningBlockSize;
			case InvalidBlockID;
			case XMLMissingRootFontElement;
			case DeserializeError;
		}

        public const int32 ImplementedVersion = 3;

        internal const uint8 MagicOne = 66;
        internal const uint8 MagicTwo = 77;
        internal const uint8 MagicThree = 70;

        public BitmapFontInfo Info { get; set; } ~ delete _;

        public BitmapFontCommon Common { get; set; } ~ delete _;

        public Dictionary<int32, String> Pages { get; set; } ~ DeleteDictionaryAndValues!(_);

        public Dictionary<int32, Character> Characters { get; set; } ~ DeleteDictionaryAndValues!(_);

        public Dictionary<KerningPair, int32> KerningPairs { get; set; } ~ delete _;

        public Result<void, SaveError> Save(String path, FormatHint formatHint)
        {
            let fileStream = scope FileStream();

			if (fileStream.Open(path, .Create, .Write, .Read) case .Err(let err))
				return .Err(.FileOpenFailed(err));

            switch (formatHint)
            {
                case FormatHint.Binary:
                {
                    Try!(WriteBinary(fileStream));

                    break;
                }

                case FormatHint.XML:
                {
					let xml = scope Xml();
					WriteXML(xml);
					xml.SaveToStream(fileStream);

                    break;
                }

                case FormatHint.Text:
                {
                    let streamWriter = scope StreamWriter(fileStream, .UTF8, 4096);
                    if (WriteText(streamWriter) case .Err)
						return .Err(.SerializeError);

                    break;
                }

                default:
                    return .Err(.UnknownFormat);
            }

			return .Ok;
        }

        public Result<void, SaveError> WriteBinary(Stream stream)
        {
			mixin STry(var result)
			{
				if (result case .Err(let err))
					return .Err(.SerializeError);
				result.Get()
			}

            STry!(stream.Write(MagicOne));
            STry!(stream.Write(MagicTwo));
            STry!(stream.Write(MagicThree));
            STry!(stream.Write((uint8)ImplementedVersion));

            if (Info != null)
            {
                STry!(stream.Write((uint8)BlockID.Info));
                STry!(Info.WriteBinary(stream));
            }

            if (Common != null)
            {
                STry!(stream.Write((uint8)BlockID.Common));
                STry!(Common.WriteBinary(stream, (int32)Pages.Count));
            }

            if (Pages != null)
            {
                STry!(stream.Write((uint8)BlockID.Pages));

				int32 totalPageLength = 0;
				for (let file in Pages.Values)
					totalPageLength += (.)file.Length + 1;

                STry!(stream.Write(totalPageLength));

                // Unlike the XML and text formats, the binary format requires page IDs to be consecutive and zero based.
				for (int32 id = 0; id < Pages.Count; id++)
				{
					String file = ?;
					if (!(Pages.TryGetValue(id, out file)))
						return .Err(.NonConsecutivePageID); // The binary format requires that page IDs be consecutive and zero based.

					STry!(stream.WriteNullTerminatedString(file));
				}
            }

            if (Characters != null)
            {
                STry!(stream.Write((uint8)BlockID.Characters));
                STry!(stream.Write((int32)Characters.Count * Character.SizeInBytes));

                for (let (id, character) in Characters)
                {
                    STry!(character.WriteBinary(stream, id));
                }
            }

            if (KerningPairs != null && KerningPairs.Count > 0)
            {
                STry!(stream.Write((uint8)BlockID.KerningPairs));
                STry!(stream.Write((int32)KerningPairs.Count * KerningPair.SizeInBytes));

                for (let (kerningPair, amount) in KerningPairs)
                {
                    STry!(kerningPair.WriteBinary(stream, amount));
                }
            }

			return .Ok;
        }

        public void WriteXML(Xml document) 
        {
            let fontElement = document.AddChild("font");

            if (Info != null)
            {
                let infoElement = fontElement.AddChild("info");
                Info.WriteXML(infoElement);
            }

            if (Common != null)
            {
                let commonElement = fontElement.AddChild("common");
                Common.WriteXML(commonElement, Pages.Count);
            }

            if (Pages != null)
            {
                let pagesElement = fontElement.AddChild("pages");

                for (let (id, file) in Pages)
                {
                    let pageElement = pagesElement.AddChild("page");
                    pageElement.SetAttribute("id", id);
                    pageElement.SetAttribute("file", file);
                }
            }

            if (Characters != null)
            {
                let charactersElement = fontElement.AddChild("chars");
                charactersElement.SetAttribute("count", Characters.Count);

                for (let (id, character) in Characters)
                {
                    let characterElement = charactersElement.AddChild("char");
                    character.WriteXML(characterElement, id);
                }
            }

            if (KerningPairs != null && KerningPairs.Count > 0)
            {
                let kerningsElement = fontElement.AddChild("kernings");
                kerningsElement.SetAttribute("count", KerningPairs.Count);

                for (let (kerningPair, amount) in KerningPairs)
                {
                    let kerningElement = kerningsElement.AddChild("kerning");
                    kerningPair.WriteXML(kerningElement, amount);
                }
            }
        }

        public Result<void> WriteText(StreamWriter textWriter) 
        {
            if (Info != null)
            {
                Try!(textWriter.Write("info"));
                Try!(Info.WriteText(textWriter));
                Try!(textWriter.WriteLine());
            }

            if (Common != null)
            {
                Try!(textWriter.Write("common"));
                Try!(Common.WriteText(textWriter, (int32)Pages.Count));
                Try!(textWriter.WriteLine());
            }

            if (Pages != null)
            {
                for (let (id, file) in Pages)
                {
                    Try!(textWriter.Write("page"));
                    Try!(TextFormatUtility.WriteInt("id", id, textWriter));
                    Try!(TextFormatUtility.WriteString("file", file, textWriter));
                	Try!(textWriter.WriteLine());
                }
            }

            if (Characters != null)
            {
                Try!(textWriter.Write("chars"));
                Try!(TextFormatUtility.WriteInt("count", (int32)Characters.Count, textWriter));
                Try!(textWriter.WriteLine());

                for (let (id, character) in Characters)
                {
                    Try!(textWriter.Write("char"));
                    Try!(character.WriteText(textWriter, id));
                	Try!(textWriter.WriteLine());
                }
            }

            if (KerningPairs != null && KerningPairs.Count > 0)
            {
                Try!(textWriter.Write("kernings"));
                Try!(TextFormatUtility.WriteInt("count", (int32)KerningPairs.Count, textWriter));
                Try!(textWriter.WriteLine());

                for (let (kerningPair, amount) in KerningPairs)
                {
                    Try!(textWriter.Write("kerning"));
                    Try!(kerningPair.WriteText(textWriter, amount));
                	Try!(textWriter.WriteLine());
                }
            }
			return .Ok;
        }

        public int GetKerningAmount(char32 left, char32 right)
        {
            if (KerningPairs == null)
            {
                return 0;
            }

            KerningPairs.TryGetValue(KerningPair((.)left, (.)right), let kerningValue);
            return kerningValue;
        }

        public Character GetCharacter(char32 character, bool tryInvalid = true)
        {
            if (Characters == null)
            {
                return null;
            }

            if (Characters.TryGetValue((.)character, var result))
            {
                return result;
            }

            if (tryInvalid && Characters.TryGetValue(-1, out result))
            {
                return result;
            }

            return null;
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> ReadBinary(Stream stream)
        {
			mixin DSTry(var result)
			{
				if (result case .Err(let err))
					return .Err(.DeserializeError);
				result.Get()
			}

            let magicOne = DSTry!(stream.Read<uint8>());
            let magicTwo = DSTry!(stream.Read<uint8>());
            let magicThree = DSTry!(stream.Read<uint8>());

            if (magicOne != MagicOne || magicTwo != MagicTwo || magicThree != MagicThree)
            {
                return .Err(.InvalidHeader); // File is not an FNT bitmap font or it is not in the binary format.
            }

            if (stream.Read<uint8>() != ImplementedVersion)
            {
                return .Err(.UnsupportedVersion); // The version specified is different from the implemented version.
            }

			let bitmapFont = new BitmapFont();

			defer
			{
				if (@return case .Err)
					delete bitmapFont;
			}

            int32 pageCount = 0;

            while (stream.Peek<uint8>() case .Ok)
            {
                let blockID = (BlockID)DSTry!(stream.Read<uint8>());

                switch (blockID)
                {
                    case BlockID.Info:
                    {
                        bitmapFont.Info = DSTry!(BitmapFontInfo.ReadBinary(stream));
                        break;
                    }
                    case BlockID.Common:
                    {
                        bitmapFont.Common = DSTry!(BitmapFontCommon.ReadBinary(stream, out pageCount));
                        break;
                    }
                    case BlockID.Pages:
                    {
                        DSTry!(stream.Read<int32>());

                        bitmapFont.Pages = new Dictionary<int32, String>(pageCount);

                        for (int32 i = 0; i < pageCount; i++)
                        {
							String page = new .();
							bitmapFont.Pages[i] = page;
							DSTry!(stream.ReadNullTerminatedString(page));
                        }

                        break;
                    }
                    case BlockID.Characters:
                    {
                        let characterBlockSize = DSTry!(stream.Read<int32>());

                        if (characterBlockSize % Character.SizeInBytes != 0)
                        {
							return .Err(.InvalidCharBlockSize);
                        }

                        let characterCount = characterBlockSize / Character.SizeInBytes;

                        bitmapFont.Characters = new Dictionary<int32, Character>(characterCount);

                        for (var i = 0; i < characterCount; i++)
                        {
                            let character = DSTry!(Character.ReadBinary(stream, let id));
                            bitmapFont.Characters[id] = character;
                        }

                        break;
                    }
                    case BlockID.KerningPairs:
                    {
                        let kerningBlockSize = DSTry!(stream.Read<int32>());

                        if (kerningBlockSize % KerningPair.SizeInBytes != 0)
                        {
							return .Err(.InvalidKerningBlockSize);
                        }

                        let kerningCount = kerningBlockSize / KerningPair.SizeInBytes;

                        bitmapFont.KerningPairs = new Dictionary<KerningPair, int32>(kerningCount);

                        for (var i = 0; i < kerningCount; i++)
                        {
                            let kerningPair = KerningPair.ReadBinary(stream, let amount);
                            if (bitmapFont.KerningPairs.ContainsKey(kerningPair)) continue;
                            bitmapFont.KerningPairs[kerningPair] = amount;
                        }

                        break;
                    }
                    default:
                    {
                        return .Err(.InvalidBlockID);
                    }
                }
            }

            return bitmapFont;
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> ReadXML(Stream stream) 
        {
			mixin DSTry(var result)
			{
				if (result case .Err(let err))
					return .Err(.DeserializeError);
				result.Get()
			}

			// Xml_Beef doesn't have errors, so let's check this here...
			{
				let position = stream.Position;

				let sr = scope StreamReader(stream, .UTF8, true, 4096);
				if (DSTry!(sr.Peek()) != '<')
					return .Err(.InvalidHeader);

				stream.Seek(position);
			}

			let document = scope Xml();
			document.LoadFromStream(stream);

            let fontElement = document.ChildNodes.Find("font");
            if (fontElement == null)
            {
                return .Err(.XMLMissingRootFontElement);
            }
			
			let bitmapFont = new BitmapFont();

			defer
			{
				if (@return case .Err)
					delete bitmapFont;
			}

            let infoElement = fontElement.Find("info");
            if (infoElement != null)
            {
                bitmapFont.Info = BitmapFontInfo.ReadXML(infoElement);
            }

            int32 pages = 0;

            let commonElement = fontElement.Find("common");
            if (commonElement != null)
            {
                bitmapFont.Common = BitmapFontCommon.ReadXML(commonElement, out pages);
            }

            let pagesElement = fontElement.Find("pages");
            if (pagesElement != null)
            {
                bitmapFont.Pages = new Dictionary<int32, String>(pages);

                for (let pageElement in pagesElement.EnumNodes("page"))
                {
                    let id = pageElement.AttributeList.GetValueOrDefault<int32>("id");
                    let name = pageElement.AttributeList.GetValueOrDefault<String>("file");
                    bitmapFont.Pages[id] = new .(name);
                }
            }

            let charactersElement = fontElement.Find("chars");
            if (charactersElement != null)
            {
                let count = charactersElement.AttributeList.GetValueOrDefault<int32>("count");

                bitmapFont.Characters = new Dictionary<int32, Character>(count);

                for (let characterElement in charactersElement.EnumNodes("char"))
                {
                    let character = Character.ReadXML(characterElement, let id);
                    bitmapFont.Characters[id] = character;
                }
            }

            let kerningsElement = fontElement.Find("kernings");
            if (kerningsElement != null)
            {
                let count = kerningsElement.AttributeList.GetValueOrDefault<int32>("count");

                bitmapFont.KerningPairs = new Dictionary<KerningPair, int32>(count);

                for (let kerningElement in kerningsElement.EnumNodes("kerning"))
                {
                    let kerningPair = KerningPair.ReadXML(kerningElement, let amount);
                    if (bitmapFont.KerningPairs.ContainsKey(kerningPair)) continue;
                    bitmapFont.KerningPairs[kerningPair] = amount;
                }
            }

            return bitmapFont;
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> ReadText(Stream stream) 
        {
			mixin DSTry(var result)
			{
				if (result case .Err(let err))
					return .Err(.DeserializeError);
				result.Get()
			}

			let bitmapFont = new BitmapFont();

			defer
			{
				if (@return case .Err)
					delete bitmapFont;
			}

			let textReader = scope StreamReader(stream, .UTF8, true, 4096);

            while (textReader.Peek() case .Ok)
            {
                let lineSegments = TextFormatUtility.GetSegments(textReader.ReadLine(.. scope .()), .. scope .());

                switch (lineSegments[0])
                {
                    case "info":
                    {
                        bitmapFont.Info = DSTry!(BitmapFontInfo.ReadText(lineSegments));
                        break;
                    }
                    case "common":
                    {
                        bitmapFont.Common = DSTry!(BitmapFontCommon.ReadText(lineSegments, let pageCount));
                        bitmapFont.Pages = new Dictionary<int32, String>(pageCount);
                        break;
                    }
                    case "page":
                    {
                        bitmapFont.Pages = bitmapFont.Pages ?? new Dictionary<int32, String>();
                        let id = DSTry!(TextFormatUtility.ReadInt("id", lineSegments));
                        let file = TextFormatUtility.ReadString("file", lineSegments);
                        bitmapFont.Pages[id] = new .(file);
                        break;
                    }
                    case "chars":
                    {
                        let count = DSTry!(TextFormatUtility.ReadInt("count", lineSegments));

                        bitmapFont.Characters = new Dictionary<int32, Character>(count);

                        for (int32 i = 0; i < count; i++)
                        {
                            let characterLineSegments = TextFormatUtility.GetSegments(textReader.ReadLine(.. scope .()), .. scope .());
                            let character = DSTry!(Character.ReadText(characterLineSegments, let id));
                            bitmapFont.Characters[id] = character;
                        }

                        break;
                    }
                    case "kernings":
                    {
                        let count = DSTry!(TextFormatUtility.ReadInt("count", lineSegments));

                        bitmapFont.KerningPairs = new Dictionary<KerningPair, int32>(count);

                        for (int32 i = 0; i < count; i++)
                        {
                            let kerningLineSegments = TextFormatUtility.GetSegments(textReader.ReadLine(.. scope .()), .. scope .());
                            let kerningPair = DSTry!(KerningPair.ReadText(kerningLineSegments, let amount));
                            if (bitmapFont.KerningPairs.ContainsKey(kerningPair)) continue;
                            bitmapFont.KerningPairs[kerningPair] = amount;
                        }

                        break;
                    }
                }
            }

            return bitmapFont;
        }

		[NoDiscard]
        public static Result<BitmapFont, ReadError> FromStream(Stream stream, FormatHint formatHint)
        {
            switch (formatHint)
            {
                case FormatHint.Binary:
                    return ReadBinary(stream);
                case FormatHint.XML:
                    return ReadXML(stream);
                case FormatHint.Text:
                    return ReadText(stream);
                default:
                    return .Err(.UnknownFormat);
            }
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> FromStream(Stream stream)
        {
			var position = stream.Position;
			var result = ReadBinary(stream);

			if (result case .Ok(let val))
				return val;
			if ((result case .Err(let err)) && err != .InvalidHeader)
				return .Err(err);

			stream.Position = position;
			result = ReadXML(stream);

			if (result case .Ok(let val))
				return val;
			if ((result case .Err(let err)) && err != .InvalidHeader)
				return .Err(err);

			stream.Position = position;
            return ReadText(stream);
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> FromFile(String path, FormatHint formatHint)
        {
			FileStream fs = scope FileStream();

			var result = fs.Open(path, .Open, .Read);
			if (result case .Err(let err))
				return .Err(.FileOpenFailed(err));

            return FromStream(fs, formatHint);
        }
		
		[NoDiscard]
        public static Result<BitmapFont, ReadError> FromFile(String path)
        {
			FileStream fs = scope FileStream();

			var result = fs.Open(path, .Open, .Read);
			if (result case .Err(let err))
				return .Err(.FileOpenFailed(err));

            return FromStream(fs);
        }
    }
}