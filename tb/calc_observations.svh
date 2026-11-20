typedef enum {
    CALC_REQ_ACCEPTED,
    CALC_RESP_CONSUMED,
    CALC_STATUS_SNAPSHOT,
    CALC_RESET_EVENT,
    CALC_REQ_BACKPRESSURE,
    CALC_RESP_BACKPRESSURE,
    CALC_PUSH_POP_EVENT,
    CALC_CLEAR_EVENT
} calc_observation_kind_t;

class calc_observation extends uvm_object;
  calc_observation_kind_t kind;
  int unsigned transaction_number;
  calc_opcode_t opcode;
  logic [7:0] operand_a;
  logic [7:0] operand_b;
  logic [15:0] rsp_result;
  calc_status_t status;
  bit clear_status;
  bit backpressure;
  bit push;
  bit pop;
  bit reset_event;

  `uvm_object_utils(calc_observation)

  function new(string name = "calc_observation");
      super.new(name);
  endfunction
endclass
