IDENTIFICATION DIVISION.
PROGRAM-ID. HELLO.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INPUT-FILE
        ASSIGN TO "input"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.

    FD INPUT-FILE.

    01 FILE-LINE.
        05 FIN PIC A(3).
        05 FX PIC A(1).
        05 FAD PIC A(4).

WORKING-STORAGE SECTION.
    01 INSTRS.
        05 INSTR PIC A(3) OCCURS 1000 TIMES.
    01 ADDRS.
        05 ADDR PIC S9(3) OCCURS 1000 TIMES.
    01 VISITED.
        05 VISIT PIC A(1) OCCURS 1000 TIMES.

    01 READ-LINE.
        05 RINSTR PIC A(3).
        05 RX PIC A(1).
        05 RADDR PIC A(4).
    01 READ-I PIC 9(3) VALUE 1.
    01 READ-EOF PIC A(1).

    01 ACCUM PIC S9(9) VALUE 0.
    01 PTR PIC 9(3) VALUE 1.
    01 CUR-INSTR PIC A(3).

    01 MOD-INSTR PIC A(3).
    01 MOD-PTR PIC 9(3) VALUE 1.

    01 SOLUTION PIC A(1).

PROCEDURE DIVISION.
    PERFORM LOAD-PRG.

    PERFORM RUN-PRG.
    DISPLAY ACCUM.

    PERFORM UNTIL SOLUTION = 'Y' OR INSTR(MOD-PTR) = SPACE
        MOVE INSTR(MOD-PTR) TO MOD-INSTR

        MOVE "sta" TO CUR-INSTR
        IF MOD-INSTR = "jmp" THEN
*>            DISPLAY "nop at" MOD-PTR
            MOVE "nop" TO INSTR(MOD-PTR)
            PERFORM RUN-PRG
        END-IF
        IF MOD-INSTR = "nop" THEN
*>            DISPLAY "jmp at" MOD-PTR
            MOVE "jmp" TO INSTR(MOD-PTR)
            PERFORM RUN-PRG
        END-IF

        IF CUR-INSTR = SPACE THEN
            MOVE 'Y' TO SOLUTION
        END-IF

        MOVE MOD-INSTR TO INSTR(MOD-PTR)
        ADD 1 TO MOD-PTR
    END-PERFORM.
    DISPLAY ACCUM.

    STOP RUN.


LOAD-PRG.
    OPEN INPUT INPUT-FILE.
    PERFORM UNTIL READ-EOF='Y'
        READ INPUT-FILE INTO READ-LINE
            AT END
                MOVE 'Y' TO READ-EOF
            NOT AT END
                COMPUTE ADDR(READ-I) = FUNCTION NUMVAL(RADDR)
                MOVE RINSTR TO INSTR(READ-I)
*>                DISPLAY READ-LINE
                ADD 1 TO READ-I
        END-READ
    END-PERFORM.
    CLOSE INPUT-FILE.

RUN-PRG.
    INITIALIZE VISITED.
    INITIALIZE ACCUM.
    MOVE 1 TO PTR.
    PERFORM UNTIL VISIT(PTR) = 'Y'
        MOVE 'Y' TO VISIT(PTR)
        MOVE INSTR(PTR) TO CUR-INSTR

        IF CUR-INSTR = "nop" THEN
*>            DISPLAY PTR "nop"
            ADD 1 TO PTR
        END-IF
        IF CUR-INSTR = "acc" THEN
*>            DISPLAY PTR "acc"
            ADD ADDR(PTR) TO ACCUM
            ADD 1 TO PTR
        END-IF
        IF CUR-INSTR = "jmp" THEN
*>            DISPLAY PTR "jmp"
            ADD ADDR(PTR) TO PTR
        END-IF
        IF CUR-INSTR = SPACE THEN
*>            DISPLAY PTR "end"
            CONTINUE
        END-IF
    END-PERFORM.