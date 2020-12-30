module Equal
(
    data1_i,
    data2_i,
    result_o
);

input   [31:0]      data1_i, data2_i;
output              result_o;

assign result_o = (data1_i == data2_i? 1:0);

endmodule 