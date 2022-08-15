module fixed_priority_arbiter(
    req,
    grant
);
parameter WIDTH = 8;

input [WIDTH-1:0] req;
output [WIDTH-1:0] grant;

assign grant = req & (~req + 1);

endmodule