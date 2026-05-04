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

## Target configuration

All targets instantiate the same `GREB_v2_base` entity, parameterised by a
`RebConfigType` record (defined in
`submodules/lsst_reb/reb_config/rtl/reb_config_pkg.vhd`).

| Field | Type | Description |
|-------|------|-------------|
| `numSequencers` | 1 or 2 | Number of sequencer instances |
| `sysClkPer` | real | System clock period (seconds) |
| `gdAddr` | 4-bit | Guard drain DAC channel address |
| `odAddr` | 4-bit | Output drain DAC channel address |
| `rdAddr` | 4-bit | Reset drain DAC channel address |
| `gdThresh` | integer×3 | Guard drain threshold per sensor |
| `odThresh` | integer×3 | Output drain threshold per sensor |
| `rdThresh` | integer×3 | Reset drain threshold per sensor |
| `reserved_1` | 32-bit | DAQ index for location-limited targets |
| `reserved_2` | 32-bit | Reserved |
| `reserved_3` | 32-bit | Reserved |

With `numSequencers=1`, a single sequencer drives both sensors.
With `numSequencers=2`, each sensor has an independent sequencer instance.

All GREB targets use the same configuration values: `gdAddr=0x0`,
`odAddr=0x5`, `rdAddr=0x1`, `gdThresh=(1138,1138,0)`,
`odThresh=(2275,2275,0)`, `rdThresh=(1632,1632,0)`. The third element is
zero because the GREB has only two active sensors.

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

See [`REGISTER_MAP.md`](common/command_interpreter/REGISTER_MAP.md) for the full register address map.

## Documentation

- Sequencer architecture: [`submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md`](submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md)
- Sequencer testbench: [`submodules/lsst_reb/sequencer_v4/TB/README.md`](submodules/lsst_reb/sequencer_v4/TB/README.md)
