/*
Battery patch SSDT for Samsung NP550P7C
Made by: Ressetkk

Please use the following Rename patches:

- name: Rename _BTP to XBTP
  find: 5F 42 54 50 09
  replace: 58 42 54 50 09
  count: 1

- name: Rename _BST to XBST
  find: 5F 42 53 54 08
  replace: 58 42 53 54 08
  count: 1

- name: Rename SBIX to SBIY
  find: 53 42 49 58 08
  replace: 53 42 49 59 08
  count: 1

Always remember to validate your ACPI tables against this SSDT and do necessary changes.
*/

DefinitionBlock ("","SSDT", 2, "ress", "BATNP550", 0)
{
    External (_SB.PCI0.LPCB.H_EC, DeviceObj) // subject of change if you rename H_EC to EC. Keep in mind you need to change all H_EC occurencies!
    
    Scope (_SB.PCI0.LPCB.H_EC)
    {
        OperationRegion (REEC, EmbeddedControl, Zero, 0xFF)
        Field (REEC, ByteAcc, NoLock, Preserve)
        {
            Offset (0x91),
            BTP0,8,BTP1,8, //BTPC
            Offset (0xA0),
            B1R0,8,B1R1,8,B1R2,8,B1R3,8, //B1RR
            B1V0,8,B1V1,8,B1V2,8,B1V3,8, //B1PV
            Offset (0xAF),
            B1A0, 8, B1A1,8,B1A2,8,B1A3,8, //B1AF
            B1L0,8,B1L1,8,B1L2,8,B1L3,8, //B1VL
            Offset (0xD0),
            CYL0,8,CYL1,8 //CYLC
        }
    }
    External (_SB.BAT1, DeviceObj)
    External (ECON, FieldUnitObj)
    External (PWRS, FieldUnitObj)
    External (RELT, FieldUnitObj)
    External (SECW, MethodObj)
    External (SECB, MethodObj)
    
    Scope(_SB.BAT1)
    {
        External (STAT, FieldUnitObj)
        External (BIFP, FieldUnitObj)
        External (BIXP, FieldUnitObj)
        
        Method (_BTP, 1, Serialized)  // _BTP: Battery Trip Point
        {
            Store (Arg0, Local0)
            If (LEqual (ECON, Zero))
            {
                SECW (0x84, 0x91, Local0)
            }
            Else
            {
                And (Local0, 0xFFFF, Local0)
                ShiftLeft (Local0, 0x08, Local1)
                And (Local1, 0xFF00, Local1)
                ShiftRight (Local0, 0x08, Local0)
                Or (Local0, Local1, Local0)
                Store (Local0, B1B2(^^PCI0.LPCB.H_EC.BTP0, ^^PCI0.LPCB.H_EC.BTP0))
            }
        }
        Method (_BST, 0, Serialized)  // _BST: Battery Status
        {
            If (LEqual (ECON, Zero))
            {
                Store (SECB (0x81, 0x84), Local0)
                If (LAnd (LNotEqual (Local0, Zero), LNotEqual (Local0, 0x05)))
                {
                    If (LEqual (PWRS, One))
                    {
                        Store (0x02, Local0)
                    }
                    Else
                    {
                        Store (One, Local0)
                    }
                }

                                Store (Local0, Index (STAT, Zero))
                                Store (SECW (0x82, 0xA4, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, One))
                                }
                                Else
                                {
                                    If (LGreaterEqual (Local0, 0x8000))
                                    {
                                        XOr (Local0, 0xFFFF, Local0)
                                        Increment (Local0)
                                    }

                                    Store (Local0, Index (STAT, One))
                                }

                                Store (SECW (0x82, 0xA2, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, 0x02))
                                }
                                Else
                                {
                                    Store (Local0, Index (STAT, 0x02))
                                }

                                Store (SECW (0x82, 0xA6, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, 0x03))
                                }
                                Else
                                {
                                    Store (Local0, Index (STAT, 0x03))
                                }
                            }
                            Else
                            {
                                Store (B1B4(^^PCI0.LPCB.H_EC.B1R0, ^^PCI0.LPCB.H_EC.B1R1, ^^PCI0.LPCB.H_EC.B1R2, ^^PCI0.LPCB.H_EC.B1R3), Local3)
                                Store (Local3, Local0)
                                And (Local0, 0xFF, Local0)
                                If (LAnd (LNotEqual (Local0, Zero), LNotEqual (Local0, 0x05)))
                                {
                                    If (LEqual (PWRS, One))
                                    {
                                        Store (0x02, Local0)
                                    }
                                    Else
                                    {
                                        Store (One, Local0)
                                    }
                                }

                                Store (Local0, Index (STAT, Zero))
                                Store (Local3, Local0)
                                ShiftRight (Local0, 0x10, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, 0x02))
                                }
                                Else
                                {
                                    Store (Local0, Index (STAT, 0x02))
                                }

                                Sleep (0x64)
                                Store (B1B4(^^PCI0.LPCB.H_EC.B1V0, ^^PCI0.LPCB.H_EC.B1V1, ^^PCI0.LPCB.H_EC.B1V2, ^^PCI0.LPCB.H_EC.B1V3), Local4)
                                Store (Local4, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, One))
                                }
                                Else
                                {
                                    If (LGreaterEqual (Local0, 0x8000))
                                    {
                                        XOr (Local0, 0xFFFF, Local0)
                                        Increment (Local0)
                                    }

                                    Store (Local0, Index (STAT, One))
                                }

                                Store (Local4, Local0)
                                ShiftRight (Local0, 0x10, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (STAT, 0x03))
                                }
                                Else
                                {
                                    Store (Local0, Index (STAT, 0x03))
                                }
                            }

                            Return (STAT)
        }
        Method (SBIX, 0, Serialized)
                        {
                            If (LEqual (ECON, Zero))
                            {
                                Store (SECW (0x82, 0xB0, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, One))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x02))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, One))
                                    Store (Local0, Index (BIXP, 0x02))
                                }

                                Store (SECW (0x82, 0xB2, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, 0x02))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x03))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x02))
                                    Store (Local0, Index (BIXP, 0x03))
                                }

                                Store (SECW (0x82, 0xB4, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, 0x04))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x05))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x04))
                                    Store (Local0, Index (BIXP, 0x05))
                                }

                                Store (SECW (0x82, 0xB6, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (Zero, Index (BIFP, 0x05))
                                    Store (Zero, Index (BIXP, 0x06))
                                    Store (Zero, Index (BIFP, 0x06))
                                    Store (Zero, Index (BIXP, 0x07))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x05))
                                    Store (Local0, Index (BIXP, 0x06))
                                    Store (Local0, Index (BIFP, 0x06))
                                    Store (Local0, Index (BIXP, 0x07))
                                }

                                If (LEqual (RELT, 0xBA))
                                {
                                    Store (Zero, Index (BIFP, 0x05))
                                    Store (Zero, Index (BIXP, 0x06))
                                    Store (Zero, Index (BIFP, 0x06))
                                    Store (Zero, Index (BIXP, 0x07))
                                }

                                Store (SECW (0x82, 0xD0, Zero), Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (Zero, Index (BIXP, 0x08))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIXP, 0x08))
                                }
                            }
                            Else
                            {
                                Store (B1B4(^^PCI0.LPCB.H_EC.B1A0, ^^PCI0.LPCB.H_EC.B1A1, ^^PCI0.LPCB.H_EC.B1A2, ^^PCI0.LPCB.H_EC.B1A3), Local3)
                                Store (B1B4(^^PCI0.LPCB.H_EC.B1L0, ^^PCI0.LPCB.H_EC.B1L1, ^^PCI0.LPCB.H_EC.B1L2, ^^PCI0.LPCB.H_EC.B1L3), Local4)
                                Store (Local3, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, One))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x02))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, One))
                                    Store (Local0, Index (BIXP, 0x02))
                                }

                                Store (Local3, Local0)
                                ShiftRight (Local0, 0x10, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, 0x02))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x03))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x02))
                                    Store (Local0, Index (BIXP, 0x03))
                                }

                                Store (Local4, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, 0x04))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x05))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x04))
                                    Store (Local0, Index (BIXP, 0x05))
                                }

                                Store (Local4, Local0)
                                ShiftRight (Local0, 0x10, Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (0xFFFFFFFF, Index (BIFP, 0x05))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x06))
                                    Store (0xFFFFFFFF, Index (BIFP, 0x06))
                                    Store (0xFFFFFFFF, Index (BIXP, 0x07))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIFP, 0x05))
                                    Store (Local0, Index (BIXP, 0x06))
                                    Store (Local0, Index (BIFP, 0x06))
                                    Store (Local0, Index (BIXP, 0x07))
                                }

                                If (LEqual (RELT, 0xBA))
                                {
                                    Store (Zero, Index (BIFP, 0x05))
                                    Store (Zero, Index (BIXP, 0x06))
                                    Store (Zero, Index (BIFP, 0x06))
                                    Store (Zero, Index (BIXP, 0x07))
                                }

                                Store (B1B2(^^PCI0.LPCB.H_EC.CYL0, ^^PCI0.LPCB.H_EC.CYL1), Local0)
                                And (Local0, 0xFFFF, Local0)
                                ShiftLeft (Local0, 0x08, Local1)
                                And (Local1, 0xFF00, Local1)
                                ShiftRight (Local0, 0x08, Local0)
                                Or (Local0, Local1, Local0)
                                If (LEqual (Local0, 0xFFFF))
                                {
                                    Store (Zero, Index (BIXP, 0x08))
                                }
                                Else
                                {
                                    Store (Local0, Index (BIXP, 0x08))
                                }
                            }

                            Return (BIFP)
        }
    }
    Method (B1B2, 2, NotSerialized) { Return (Or (Arg0, ShiftLeft (Arg1, 8))) }
    Method (B1B4, 4, NotSerialized)
    {
        Store(Arg3, Local0)
        Or(Arg2, ShiftLeft(Local0, 8), Local0)
        Or(Arg1, ShiftLeft(Local0, 8), Local0)
        Or(Arg0, ShiftLeft(Local0, 8), Local0)
        Return(Local0)
    }
}