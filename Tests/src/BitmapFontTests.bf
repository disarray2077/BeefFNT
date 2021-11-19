//**************************************************************************************************
// BitmapFontCommonTests.bf                                                                        *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.IO;
using System.Collections;
using Xml_Beef;

using internal BeefFNT;

namespace BeefFNT.Tests
{
	static class BitmapFontTests
	{
		public static readonly BitmapFont TestFont = new BitmapFont()
		{
		    Info = new BitmapFontInfo()
		    {
		        Bold = true,
		        Italic = true,
		        Charset = CharacterSet.ANSI.ToString(.. scope .()),
		        Face = "Test",
		        Outline = 5,
		        PaddingRight = 1,
		        PaddingUp = 2,
		        PaddingLeft = 3,
		        PaddingDown = 4,
		        Size = 7,
		        SpacingHorizontal = 8,
		        SpacingVertical = 9,
		        Smooth = true,
		        Unicode = false,
		        StretchHeight = 10,
		        SuperSamplingLevel = 11
		    },
		    Common = new BitmapFontCommon()
		    {
		        LineHeight = 12,
		        AlphaChannel = ChannelData.Glyph,
		        Base = 13,
		        BlueChannel = ChannelData.GlyphAndOutline,
		        GreenChannel = ChannelData.One,
		        Packed = true, 
		        RedChannel = ChannelData.Outline,
		        ScaleWidth = 14,
		        ScaleHeight = 15
		    },
		    Pages = new Dictionary<int32, String>()
		    {
		        ( 0, new String("Page_0.png") ),
		        ( 1, new String("Page_0.png") ),
		        ( 2, new String("Page_0.png") )
		    },
		    Characters = new Dictionary<int32, Character>()
		    {
		        ( (int32)'A', new Character()
		            {
		                Channel = Channel.All,
		                Height = 16,
		                Page = 17,
		                Width = 18,
		                X = 19,
		                XAdvance = -20,
		                XOffset = 21,
		                Y = 22,
		                YOffset = 23
		            }
		        ),
		        ( (int32)'B', new Character()
		            {
		                Channel = Channel.Alpha,
		                Height = 24,
		                Page = 25,
		                Width = 26,
		                X = 27,
		                XAdvance = 28,
		                XOffset = -29,
		                Y = 30,
		                YOffset = 31
		            }
		        ),
		        ( (int32)'C', new Character()
		            {
		                Channel = Channel.Blue,
		                Height = 32,
		                Page = 33,
		                Width = 34,
		                X = 35,
		                XAdvance = 36,
		                XOffset = 37,
		                Y = 38,
		                YOffset = -39
		            }
		        )   
		    },
		    KerningPairs = new Dictionary<KerningPair, int32>()
		    {
		        ( KerningPair((int32)'A', (int32)'B'), 40 ),
		        ( KerningPair((int32)'B', (int32)'C'), -41 ),
		        ( KerningPair((int32)'A', (int32)'C'), 42 )
		    }
		} ~ delete _;

		// Binary

		[Test]
		public static void ReadBinaryWrongMagic()
		{
		    var memoryStream = scope MemoryStream();

            memoryStream.Write(BitmapFont.MagicOne - 1);
            memoryStream.Write(BitmapFont.MagicTwo + 1);
            memoryStream.Write(BitmapFont.MagicThree);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void ReadBinaryWrongVersion()
		{
		    var memoryStream = scope MemoryStream();

            memoryStream.Write(BitmapFont.MagicOne);
            memoryStream.Write(BitmapFont.MagicTwo);
            memoryStream.Write(BitmapFont.MagicThree);
            memoryStream.Write((uint8)0);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void ReadBinary()
		{
		    var result = BitmapFont.FromFile("./res/TestFontBinary.fnt", FormatHint.Binary).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void AutoReadBinary()
		{
			var result = BitmapFont.FromFile("./res/TestFontBinary.fnt").Get();
		    Compare(result, TestFont);
			delete result;
		}

		[Test]
		public static void ReadBackBinary()
		{
		    TestFont.Save("SaveTestBinary.fnt", FormatHint.Binary);

		    var result = BitmapFont.FromFile("SaveTestBinary.fnt", FormatHint.Binary).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void ReadBinaryCharactersWrongBlockSize()
		{
		    var memoryStream = scope MemoryStream();

            memoryStream.Write(BitmapFont.MagicOne);
            memoryStream.Write(BitmapFont.MagicTwo);
            memoryStream.Write(BitmapFont.MagicThree);
            memoryStream.Write((uint8)BitmapFont.ImplementedVersion);
            memoryStream.Write((uint8)BlockID.Characters);
            memoryStream.Write(25);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void ReadBinaryKerningWrongBlockSize()
		{
		    var memoryStream = scope MemoryStream();

            memoryStream.Write(BitmapFont.MagicOne);
            memoryStream.Write(BitmapFont.MagicTwo);
            memoryStream.Write(BitmapFont.MagicThree);
            memoryStream.Write((uint8)BitmapFont.ImplementedVersion);
            memoryStream.Write((uint8)BlockID.KerningPairs);
            memoryStream.Write(KerningPair.SizeInBytes / 2);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void WriteBinaryInvalidPageIndices()
		{
		    var bitmapFont = scope BitmapFont()
		    {
		        Pages = new Dictionary<int32, String>()
		        {
		            ( (int32)0, new String("One.png") ),
		            ( (int32)2, new String("One.png") ),
		            ( (int32)3, new String("One.png") )
		        }
		    };

		    var memoryStream = scope MemoryStream();
		    var result = bitmapFont.WriteBinary(memoryStream);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void ReadBinaryInvalidBlock()
		{
		    var memoryStream = scope MemoryStream();

            memoryStream.Write(BitmapFont.MagicOne);
            memoryStream.Write(BitmapFont.MagicTwo);
            memoryStream.Write(BitmapFont.MagicThree);
            memoryStream.Write((uint8)BitmapFont.ImplementedVersion);
            memoryStream.Write((uint8)6);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void ReadBinaryKerningDuplicate()
		{
		    const char8 first = 'A';
		    const char8 second = 'B';
		    const int expected = 1;

		    var memoryStream = scope MemoryStream();

	        var kerningPair = KerningPair((int32)first, (int32)second);

            memoryStream.Write(BitmapFont.MagicOne);
            memoryStream.Write(BitmapFont.MagicTwo);
            memoryStream.Write(BitmapFont.MagicThree);
            memoryStream.Write((uint8)BitmapFont.ImplementedVersion);
            memoryStream.Write((uint8)BlockID.KerningPairs);
            memoryStream.Write(KerningPair.SizeInBytes * 2);
            kerningPair.WriteBinary(memoryStream, expected);
            kerningPair.WriteBinary(memoryStream, expected + 1);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Binary).Get();
	        Assert.AreEqual(expected, result.GetKerningAmount(first, second));
			delete result;
		}

		// XML

		[Test]
		public static void ReadXML()
		{
		    var result = BitmapFont.FromFile("./res/TestFontXML.fnt", FormatHint.XML).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void AutoReadXML()
		{
			var result = BitmapFont.FromFile("./res/TestFontXML.fnt").Get();
		    Compare(result, TestFont);
			delete result;
		}

		[Test]
		public static void ReadBackXML()
		{
		    TestFont.Save("SaveTestXML.fnt", FormatHint.XML);

		    var result = BitmapFont.FromFile("SaveTestXML.fnt", FormatHint.XML).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void ReadXMLKerningDuplicate()
		{
		    const char8 first = 'A';
		    const char8 second = 'B';
		    const int32 expected = 1;

		    var memoryStream = scope MemoryStream();

	        var kerningPair = KerningPair((int32)first, (int32)second);

	        var document = scope Xml();
	        {
	            var fontElement = document.AddChild("font");

	            var kerningsElement = fontElement.AddChild("kernings");
	            kerningsElement.SetAttribute("count", 2);

	            for (int32 i = 0; i < 2; i++)
	            {
	                var kerningElement = kerningsElement.AddChild("kerning");
	                kerningPair.WriteXML(kerningElement, expected + i);
	            }
	        }

			document.SaveToStream(memoryStream);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.XML).Get();
	        Assert.AreEqual(expected, result.GetKerningAmount(first, second));
			delete result;
		}

		[Test]
		public static void ReadXMLMissingRoot()
		{
		    var memoryStream = scope MemoryStream();

	        var document = scope Xml();
	        {
	            document.AddChild("nothing");
	        }

			document.SaveToStream(memoryStream);

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.XML);
			Assert.IsFalse(result case .Ok);
		}

		// Text

		[Test]
		public static void ReadText()
		{
		    var result = BitmapFont.FromFile("./res/TestFontText.fnt", FormatHint.Text).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void AutoReadText()
		{
			var result = BitmapFont.FromFile("./res/TestFontText.fnt").Get();
		    Compare(result, TestFont);
			delete result;
		}

		[Test]
		public static void ReadBackText()
		{
		    TestFont.Save("SaveTestText.fnt", FormatHint.Text);
		    var result = BitmapFont.FromFile("SaveTestText.fnt", FormatHint.Text).Get();
		    Compare(TestFont, result);
			delete result;
		}

		[Test]
		public static void ReadTextKernelDuplicate()
		{
		    const char8 first = 'A';
		    const char8 second = 'B';
		    const int32 expected = 1;

		    var memoryStream = scope MemoryStream();

	        var kerningPair = KerningPair((int32)first, (int32)second);

	        {
				var streamWriter = scope StreamWriter(memoryStream, .UTF8, 1024);

	            streamWriter.Write("kernings");
	            TextFormatUtility.WriteInt("count", 2, streamWriter);
	            streamWriter.WriteLine();

	            for (int32 i = 0; i < 2; i++)
	            {
	                streamWriter.Write("kerning");
	                kerningPair.WriteText(streamWriter, expected + i);
	                streamWriter.WriteLine();
	            }
	        }

	        memoryStream.Seek(0);

	        var result = BitmapFont.FromStream(memoryStream, FormatHint.Text).Get();
	        Assert.AreEqual(expected, result.GetKerningAmount(first, second));
			delete result;
		}

		// Misc IO

		[Test]
		public static void FromStreamBadFormatHint()
		{
			var result = BitmapFont.FromStream(null, (FormatHint)3);
			Assert.IsFalse(result case .Ok);
		}

		[Test]
		public static void SaveBadFormatHint()
		{
		    var bitmapFont = scope BitmapFont();
		    var result = bitmapFont.Save("InvalidFormatHint.fnt", (FormatHint)3);
			Assert.IsFalse(result case .Ok);
		}

		// Kerning

		[Test]
		public static void GetKerning()
		{
		    var bitmapFont = scope BitmapFont()
		    {
		        KerningPairs = new Dictionary<KerningPair, int32>() { ( KerningPair(2, 6), (int32)5 ) }
		    };

		    var kerningAmount = bitmapFont.GetKerningAmount((char8)2, (char8)6);
		    Assert.AreEqual(kerningAmount, 5);
		}

		[Test]
		public static void GetKerningWhenNull()
		{
		    var bitmapFont = scope BitmapFont()
		    {
		        KerningPairs = null
		    };

		    var kerningAmount = bitmapFont.GetKerningAmount((char8)2, (char8)6);
		    Assert.AreEqual(kerningAmount, 0);
		}

		// Character

		[Test]
		public static void GetCharacter()
		{
		    var character = new Character();

		    var bitmapFont = scope BitmapFont()
		    {
		        Characters = new Dictionary<int32, Character>()
		        {
		            ( (int32)5, character )
		        }
		    };

		    Assert.AreEqual(character, bitmapFont.GetCharacter((char8)5));
		}

		[Test]
		public static void GetInvalidCharacter()
		{
		    var character = new Character();

		    var bitmapFont = scope BitmapFont()
		    {
		        Characters = new Dictionary<int32, Character>()
		        {
		            ( (int32)-1, character )
		        }
		    };

		    Assert.AreEqual(character, bitmapFont.GetCharacter((char8)5));
		}

		[Test]
		public static void GetMissingCharacter()
		{
		    var character = new Character();

		    var bitmapFont = scope BitmapFont()
		    {
		        Characters = new Dictionary<int32, Character>()
		        {
		            ( (int32)-1, character )
		        }
		    };

		    Assert.AreEqual((Character)null, bitmapFont.GetCharacter((char8)5, false));
		}

		[Test]
		public static void GetCharacterWhenNull()
		{
		    var bitmapFont = scope BitmapFont();
		    Assert.AreEqual((Character)null, bitmapFont.GetCharacter((char8)5));
		}

		// Utility

		private static void Compare(BitmapFont one, BitmapFont two)
		{
		    Assert.AreEqual(one.Info == null, two.Info == null, "An info equals null.");

		    if (one.Info != null)
		    {
		        Assert.AreEqual(one.Info.Unicode, two.Info.Unicode, "Unicode incorrect.");
		        Assert.AreEqual(one.Info.Bold, two.Info.Bold, "Bold incorrect.");
		        Assert.AreEqual(one.Info.Charset, two.Info.Charset, "Charset incorrect.");
		        Assert.AreEqual(one.Info.Face, two.Info.Face, "Face incorrect.");
		        Assert.AreEqual(one.Info.Italic, two.Info.Italic, "Italic incorrect.");
		        Assert.AreEqual(one.Info.Outline, two.Info.Outline, "Outline incorrect.");
		        Assert.AreEqual(one.Info.PaddingDown, two.Info.PaddingDown, "PaddingDown incorrect.");
		        Assert.AreEqual(one.Info.PaddingLeft, two.Info.PaddingLeft, "PaddingLeft incorrect.");
		        Assert.AreEqual(one.Info.PaddingRight, two.Info.PaddingRight, "PaddingRight incorrect.");
		        Assert.AreEqual(one.Info.PaddingUp, two.Info.PaddingUp, "PaddingUp incorrect.");
		        Assert.AreEqual(one.Info.Size, two.Info.Size, "Size incorrect.");
		        Assert.AreEqual(one.Info.Smooth, two.Info.Smooth, "Smooth incorrect.");
		        Assert.AreEqual(one.Info.SpacingHorizontal, two.Info.SpacingHorizontal, "SpacingHorizontal incorrect.");
		        Assert.AreEqual(one.Info.SpacingVertical, two.Info.SpacingVertical, "SpacingVertical incorrect.");
		        Assert.AreEqual(one.Info.StretchHeight, two.Info.StretchHeight, "StretchHeight incorrect.");
		        Assert.AreEqual(one.Info.Outline, two.Info.Outline, "Outline incorrect.");
		        Assert.AreEqual(one.Info.SuperSamplingLevel, two.Info.SuperSamplingLevel, "SuperSamplingLevel incorrect.");
		    }

		    Assert.AreEqual(one.Common == null, two.Common == null, "A common equals null.");

		    if (one.Common != null)
		    {
		        Assert.AreEqual(one.Common.AlphaChannel, two.Common.AlphaChannel, "AlphaChannel incorrect.");
		        Assert.AreEqual(one.Common.Base, two.Common.Base, "Base incorrect.");
		        Assert.AreEqual(one.Common.BlueChannel, two.Common.BlueChannel, "BlueChannel incorrect.");
		        Assert.AreEqual(one.Common.GreenChannel, two.Common.GreenChannel, "GreenChannel incorrect.");
		        Assert.AreEqual(one.Common.LineHeight, two.Common.LineHeight, "LineHeight incorrect.");
		        Assert.AreEqual(one.Common.Packed, two.Common.Packed, "Packed incorrect.");
		        Assert.AreEqual(one.Common.RedChannel, two.Common.RedChannel, "Red channel incorrect.");
		        Assert.AreEqual(one.Common.ScaleHeight, two.Common.ScaleHeight, "ScaleHeight incorrect.");
		        Assert.AreEqual(one.Common.ScaleWidth, two.Common.ScaleWidth, "ScaleWidth incorrect.");
		    }
			
			Assert.AreEqual(one.Pages == null, two.Pages == null, "A page dictionary equals null.");
		    Assert.AreEqual(one.Pages.Count, two.Pages.Count, "Page count incorrect.");

		    if (one.Pages != null)
		    {
		        for (var (key, page) in one.Pages)
		        {
		            if (!two.Pages.TryGetValue(key, var value) || value != page)
		            {
		                Assert.Fail("Page not found.");
		            }
		        }
		    }
			
			Assert.AreEqual(one.Characters == null, two.Characters == null, "A character dictionary equals null.");
		    Assert.AreEqual(one.Characters.Count, two.Characters.Count, "Character count incorrect.");

		    if (one.Characters != null)
		    {
		        for (var (key, character) in one.Characters)
		        {
		            if (!two.Characters.TryGetValue(key, var value))
		            {
		                Assert.Fail("Character not found.");
		            }

		            Assert.AreEqual(character.Channel, value.Channel, "Channel incorrect.");
		            Assert.AreEqual(character.Height, value.Height, "Height incorrect.");
		            Assert.AreEqual(character.Page, value.Page, "Page incorrect.");
		            Assert.AreEqual(character.Width, value.Width, "Width incorrect.");
		            Assert.AreEqual(character.X, value.X, "X incorrect.");
		            Assert.AreEqual(character.Y, value.Y, "Y incorrect.");
		            Assert.AreEqual(character.XAdvance, value.XAdvance, "XAdvance incorrect.");
		            Assert.AreEqual(character.XOffset, value.XOffset, "XOffset incorrect.");
		            Assert.AreEqual(character.YOffset, value.YOffset, "YOffset incorrect.");
		        }
		    }
			
			Assert.AreEqual(one.KerningPairs == null, two.KerningPairs == null, "A kerning dictionary equals null.");
		    Assert.AreEqual(one.KerningPairs.Count, two.KerningPairs.Count, "kerningPair count incorrect.");

		    if (one.KerningPairs != null)
		    {
		        for (var (pair, amount) in one.KerningPairs)
		        {
		            if (!two.KerningPairs.TryGetValue(pair, var value))
		            {
		                Assert.Fail("KerningPair not found.");
		            }

		            Assert.AreEqual(amount, value, "Amount incorrect.");
		        }
		    }
		}
	}
}
