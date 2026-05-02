# GREB_v2

Firmware for the LSST Guider Raft Electronics Board (GREB), version 2.
Targets a Xilinx Kintex-7 (XC7K160T) FPGA. Built with the ruckus framework
and Vivado. The GREB drives two guider sensors.

## Build targets

| Target | System clock | Sequencers |
|--------|--------------|------------|
| `GREB_v2` | 10 ns (100 MHz) | 1 |
| `GREB_v2_6p4ns` | 6.4 ns (156.25 MHz) | 1 |
| `GREB_v2_2_seq` | 10 ns (100 MHz) | 2 |
| `GREB_v2_6p4ns_2_seq` | 6.4 ns (156.25 MHz) | 2 |

All targets use the same RTL and produce identical register-level behaviour.

## Repository layout

| Path | Contents |
|------|----------|
| `targets/GREB_v2/` | Top-level entity, constraints, build scripts, binary images |
| `targets/GREB_v2_6p4ns/` | Same structure, 6.4 ns variant |
| `targets/GREB_v2_2_seq/` | Same structure, dual sequencer |
| `targets/GREB_v2_6p4ns_2_seq/` | Same structure, 6.4 ns + dual sequencer |
| `common/command_interpreter/` | Register decode and command routing |
| `common/greb_v2_base/` | Board-level integration entity |
| `submodules/` | External dependencies (see below) |
| `build/` | Vivado project trees (local, not committed) |

## Submodules

| Submodule | Purpose |
|-----------|---------|
| `lsst_reb` | Shared REB IP library (sequencer, peripheral drivers) |
| `lsst_sci` | Science data path (PGP, image readout) |
| `surf` | SLAC firmware utilities |
| `ruckus` | Build framework |

## Building

Builds require Vivado 2025.1 and are run via ruckus:

```
cd targets/GREB_v2
make
```

Binary outputs (`.bit.gz`, `.mcs.gz`) are committed to
`targets/<target>/images/`.

## Register map

See [`REGISTERS.md`](REGISTERS.md) for the full register address map.

## Documentation

- Sequencer architecture: [`submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md`](submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md)
- Sequencer testbench: [`submodules/lsst_reb/sequencer_v4/TB/README.md`](submodules/lsst_reb/sequencer_v4/TB/README.md)
