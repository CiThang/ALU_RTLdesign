module AND (
    input a,b,
    output r
);
    
    assign r = a&b;
endmodule

module  OR (
    input a,b,
    output r
);
    assign r = a|b;
endmodule

module NOT (
    input a,
    output r
);
    assign r = ~a;
endmodule

module NOR(
    input a,b,
    output r
);
    reg r_t;

    OR or(
        .a(a),
        .b(b),
        .r(r_t)
    );

    NOT not(
        .a(r_t),
        .r(r)
    );
endmodule

module NAND(
    input a,b,
    output r
);
    reg r_t;

    AND and(
        .a(a),
        .b(b),
        .r(r_t)
    );

    NOT not(
        .a(r_t),
        .r(r)
    );
endmodule

module XOR(
    input a,b,
    output r
);
    reg x,y;
    reg n_a,n_b;

    NOT nota(
        .a(a),
        .r(n_a)
    );

    NOT notb(
        .a(b),
        .r(n_b)
    );

    AND andx(
        .a(a),
        .b(n_b),
        .r(x)
    );

    AND andy(
        .a(n_a),
        .b(b),
        .r(y)
    );

    OR or(
        .a(x),
        .b(y),
        .r(r)
    );

endmodule