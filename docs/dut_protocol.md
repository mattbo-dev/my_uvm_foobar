# DUT Protocol

## Request handshake

A request is accepted at a rising edge when `req_valid && req_ready`.
`req_valid`, opcode, and operands remain stable while `req_valid && !req_ready`.
Invalid requests are accepted even when the FIFO is full. Valid requests wait
until FIFO capacity exists.

## Response handshake

`rsp_valid` is high whenever occupancy is nonzero. `rsp_result` is the oldest
FIFO entry. A response is consumed at a rising edge when
`rsp_valid && rsp_ready`. The result remains stable while valid and not ready.

## FIFO

The four-entry FIFO supports separate push and pop, including simultaneous
push/pop. Occupancy ranges from zero through four. A full FIFO deasserts
`req_ready` for valid operations. Invalid operations do not enqueue.

## Reset and status

Reset is synchronous and active-low. It clears the FIFO pointers/count, sticky
bits, and `last_result`. Clear status clears both sticky bits but not FIFO,
occupancy, or last result. If clear and a sticky event occur together, the new
sticky event remains set.
