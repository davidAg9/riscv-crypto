
/*
 * file: riscv_insts_crypto.sail
 *
 * This file contains instructions whos definitions do not change whether
 * XLEN is 32 or 64.
 *
 * This file must be included in the model build whatever the value of XLEN.
 *
 */

/*
 * Scalar Cryptography Extension - Scalar        SHA256 instructions
 * ----------------------------------------------------------------------
 */

/* AST clauses for the SHA256 instructions. */
union   clause ast    =    SHA256_SIG0 : (regidx,regidx)
union   clause ast    =    SHA256_SIG1 : (regidx,regidx)
union   clause ast    =    SHA256_SUM0 : (regidx,regidx)
union   clause ast    =    SHA256_SUM1 : (regidx,regidx)


/* Encode/decode mappings for the SHA256 instructions. */
mapping clause encdec =    SHA256_SIG0   (rs1,rd) <->
    0b000011100000 @ rs1 @ 0b111 @ rd @ 0b0101011

mapping clause encdec =    SHA256_SIG1   (rs1,rd) <->
    0b000011100001 @ rs1 @ 0b111 @ rd @ 0b0101011

mapping clause encdec =    SHA256_SUM0   (rs1,rd) <->
    0b000011100010 @ rs1 @ 0b111 @ rd @ 0b0101011

mapping clause encdec =    SHA256_SUM1   (rs1,rd) <->
    0b000011100011 @ rs1 @ 0b111 @ rd @ 0b0101011


/* Assembly string mappings for the SHA256 instructions. */
mapping clause assembly = SHA256_SIG0 (rs1,rd) <-> "sha256sig0" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)
mapping clause assembly = SHA256_SIG1 (rs1,rd) <-> "sha256sig1" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)
mapping clause assembly = SHA256_SUM0 (rs1,rd) <-> "sha256sum0" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)
mapping clause assembly = SHA256_SUM1 (rs1,rd) <-> "sha256sum1" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)

val      crypto_sha256 : (sha256_op, regidx, regidx) -> Retired effect {escape,rreg,wreg}
/* --- specification snippet begin --- */
function crypto_sha256   (op        , rd    , rs1   ) =  {
  let inb    : bits(32) = X(rs1)[31..0];
  let result : bits(32) = match op {
    OP_SHA256_SIG0 => ror32(inb ,07) ^ ror32(inb ,18) ^ (inb >>  3),
    OP_SHA256_SIG1 => ror32(inb ,17) ^ ror32(inb ,19) ^ (inb >> 10),
    OP_SHA256_SUM0 => ror32(inb , 2) ^ ror32(inb, 13) ^ ror32(inb,22),
    OP_SHA256_SUM1 => ror32(inb , 6) ^ ror32(inb, 11) ^ ror32(inb,25)
  };
  X(rd) = EXTZ(result);
  RETIRE_SUCCESS
}
/* --- specification snippet end --- */

/* Execution clauses for the SHA256 instructions. */
function clause execute (SHA256_SIG0 (rs1,rd)) = {
    crypto_sha256(OP_SHA256_SIG0, rd, rs1);
}

function clause execute (SHA256_SIG1 (rs1,rd)) = {
    crypto_sha256(OP_SHA256_SIG1, rd, rs1);
}

function clause execute (SHA256_SUM0 (rs1,rd)) = {
    crypto_sha256(OP_SHA256_SUM0, rd, rs1);
}

function clause execute (SHA256_SUM1 (rs1,rd)) = {
    crypto_sha256(OP_SHA256_SUM1, rd, rs1);
}

/*
 * Scalar Cryptography Extension - Scalar        SM3 instructions
 * ----------------------------------------------------------------------
 */


/* AST Types for SM3.p0/1 */
union   clause ast      =  SM3_P0 : (regidx,regidx)
union   clause ast      =  SM3_P1 : (regidx,regidx)

/* Decode clause for sm3.p0 */
mapping clause encdec   =  SM3_P0   (rs1,rd) <->
    0b000011101000 @ rs1 @ 0b111 @ rd @ 0b0101011

/* Decode clause for sm3.p1 */
mapping clause encdec   =  SM3_P1   (rs1,rd) <->
    0b000011101001 @ rs1 @ 0b111 @ rd @ 0b0101011


/* Asssembly code mapping for sm3.p0 */
mapping clause assembly =  SM3_P0 (rs1,rd) <->
    "sm3.p0" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)

/* Asssembly code mapping for sm3.p1 */
mapping clause assembly =  SM3_P1 (rs1,rd) <->
    "sm3.p1" ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1)


val      crypto_sm3 : (sm3_op, regidx, regidx) -> Retired effect {escape,rreg,wreg}
/* --- specification snippet begin --- */
function crypto_sm3   (op     , rd    , rs1   ) =  {
  let r1    : bits(32) = X(rs1)[31..0];
  let result  : bits(32) = match op {
    P0  => r1 ^ rol32(r1 , 9) ^ rol32(r1 ,17),
    P1  => r1 ^ rol32(r1 ,15) ^ rol32(r1 ,23)
  };
  X(rd)       = EXTZ(result);
  RETIRE_SUCCESS
}
/* --- specification snippet end --- */


/* Execute clause for sm3.p0 */
function clause execute ( SM3_P0 (rs1,rd)) = {
  crypto_sm3(P0, rd, rs1);
}

/* Execute clause for sm3.p1 */
function clause execute ( SM3_P1 (rs1,rd)) = {
  crypto_sm3(P1, rd, rs1);
}


/*
 * Scalar Cryptography Extension - Scalar        SM4 instructions
 * ----------------------------------------------------------------------
 */


/* AST clauses for the SM4 instructions. */
union   clause ast      = SM4_ED : (bits(2),regidx,regidx,regidx)
union   clause ast      = SM4_KS : (bits(2),regidx,regidx,regidx)


/* Encode / decode mappings for the SM4 instructions. */
mapping clause encdec   = SM4_ED   (bs,rs2,rs1,rd) <->
    bs @ 0b00100 @ rs2 @ rs1 @ 0b011 @ rd @ 0b0101011

mapping clause encdec   = SM4_KS   (bs,rs2,rs1,rd) <->
    bs @ 0b00101 @ rs2 @ rs1 @ 0b011 @ rd @ 0b0101011


/* Assembly string mappings for the SM4 instructions. */
mapping clause assembly = SM4_ED (bs,rs2,rs1,rd) <->
    "sm4.ed"     ^ spc() ^ 
    reg_name(rd)  ^ sep() ^
    reg_name(rs1) ^ sep() ^
    reg_name(rs2) ^ sep() ^ hex_bits_2(bs)

mapping clause assembly = SM4_KS (bs,rs2,rs1,rd) <->
    "sm4.ks"     ^ spc() ^
    reg_name(rd)  ^ sep() ^
    reg_name(rs1) ^ sep() ^
    reg_name(rs2) ^ sep() ^ hex_bits_2(bs)


/* Execute clause for the sm4 instructions. */
/* --- specification snippet begin --- */
function clause execute (SM4_ED (bs,rs2,rs1,rd)) = {
  let shamt : bits(6)  = (0b0 @ bs @ 0b000); /* shamt = bs*8 */
  let sb_in : bits(8)  = (X(rs2) >> shamt)[7..0];
  let x     : bits(32) = 0x000000 @ sm4_sbox(sb_in);
  let y     : bits(32) = x ^  (x               <<  8) ^ ( x               <<  2) ^
                              (x               << 18) ^ ((x & 0x0000003F) << 26) ^
                             ((x & 0x000000C0) << 10);
  let z     : bits(32) = (y << shamt) ^ (y >> (0b100000-shamt));
  let result: bits(32) = z ^ X(rs1)[31..0];
  X(rd)                = EXTZ(result);
  RETIRE_SUCCESS
}

function clause execute (SM4_KS (bs,rs2,rs1,rd)) = {
  let shamt : bits(6)  = (0b0 @ bs @ 0b000); /* shamt = bs*8 */
  let sb_in : bits(8)  = (X(rs2) >> shamt)[7..0];
  let x     : bits(32) = 0x000000 @ sm4_sbox(sb_in);
  let y     : bits(32) = x ^ ((x & 0x00000007) << 29) ^ ((x & 0x000000FE) <<  7) ^
                             ((x & 0x00000001) << 23) ^ ((x & 0x000000F8) << 13) ;
  let z     : bits(32) = (y << shamt) ^ (y >> (0b100000-shamt));
  let result: bits(32) = z ^ X(rs1)[31..0];
  X(rd)                = EXTZ(result);
  RETIRE_SUCCESS
}
/* --- specification snippet end --- */

