//**************************************************************************************************
// UtilityExtensions.bf                                                                            *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.Diagnostics;

namespace BeefFNT
{
    static
    {
        internal static bool IsBitSet(this uint8 byte, int index)
        {
            Debug.Assert(index >= 0 && index <= 7);
            return (byte & (1 << index)) != 0;
        }

        internal static uint8 SetBit(this uint8 byte, int index, bool set)
        {
            Debug.Assert(index >= 0 && index <= 7);

            if (set)
            {
                return (uint8)(byte | (1 << index));
            }

            return (uint8)(byte & ~(1 << index));
        }
    }
}