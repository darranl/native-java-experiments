# libgpiod API Quick Reference

**Version:** libgpiod v1.6.3 (v1 API — not v2)
**Header:** `/home/darranl/mnt/pios12_root/usr/include/gpiod.h`
**Include:** `#include <gpiod.h>`
**Link flag:** `-lgpiod`
**Error handling:** int-returning functions return -1 on error; pointer-returning functions return NULL. errno is always set.

---

## Key Types

| Type | Kind | Description |
|---|---|---|
| `struct gpiod_chip` | opaque | Represents an open GPIO chip (`/dev/gpiochipN`) |
| `struct gpiod_line` | opaque | Represents a single GPIO line (pin) |
| `struct gpiod_line_bulk` | **concrete** | Holds up to 64 line pointers + count (see below) |
| `struct gpiod_chip_iter` | opaque | Iterator over all chips in `/dev/` |
| `struct gpiod_line_iter` | opaque | Iterator over all lines on a chip |
| `struct gpiod_line_request_config` | **concrete** | Config passed to `gpiod_line_request()` |
| `struct gpiod_line_event` | **concrete** | Event data (timestamp + type) |
| `gpiod_ctxless_set_value_cb` | typedef | `void (*)(void *)` — callback for ctxless set |
| `gpiod_ctxless_event_handle_cb` | typedef | `int (*)(int, unsigned int, const struct timespec *, void *)` |
| `gpiod_ctxless_event_poll_cb` | typedef | `int (*)(unsigned int, struct gpiod_ctxless_event_poll_fd *, const struct timespec *, void *)` |

### `struct gpiod_line_bulk` layout

```c
#define GPIOD_LINE_BULK_MAX_LINES 64

struct gpiod_line_bulk {
    struct gpiod_line *lines[GPIOD_LINE_BULK_MAX_LINES];
    unsigned int num_lines;
};

// Static initialiser — sets num_lines to 0
#define GPIOD_LINE_BULK_INITIALIZER  { { NULL }, 0 }
```

### `struct gpiod_line_request_config` layout

```c
struct gpiod_line_request_config {
    const char *consumer;   // name of the consumer (shown in gpioinfo)
    int request_type;       // one of GPIOD_LINE_REQUEST_DIRECTION_* or EVENT_*
    int flags;              // OR of GPIOD_LINE_REQUEST_FLAG_* values
};
```

### `struct gpiod_line_event` layout

```c
struct gpiod_line_event {
    struct timespec ts;   // best estimate of event time
    int event_type;       // GPIOD_LINE_EVENT_RISING_EDGE or FALLING_EDGE
};
```

---

## Chip Operations

```c
// Open by various identifiers — all return NULL on error
struct gpiod_chip *gpiod_chip_open           (const char *path);        // e.g. "/dev/gpiochip0"
struct gpiod_chip *gpiod_chip_open_by_name   (const char *name);        // e.g. "gpiochip0"
struct gpiod_chip *gpiod_chip_open_by_number (unsigned int num);        // e.g. 0
struct gpiod_chip *gpiod_chip_open_by_label  (const char *label);       // kernel label
struct gpiod_chip *gpiod_chip_open_lookup    (const char *descr);       // tries all of the above

void        gpiod_chip_close    (struct gpiod_chip *chip);
const char *gpiod_chip_name     (struct gpiod_chip *chip);  // e.g. "gpiochip0"
const char *gpiod_chip_label    (struct gpiod_chip *chip);  // kernel label
unsigned int gpiod_chip_num_lines(struct gpiod_chip *chip); // total line count
```

---

## Line Retrieval

```c
// From a chip
struct gpiod_line *gpiod_chip_get_line  (struct gpiod_chip *chip, unsigned int offset);
struct gpiod_line *gpiod_chip_find_line (struct gpiod_chip *chip, const char *name);

int gpiod_chip_get_lines    (struct gpiod_chip *chip, unsigned int *offsets,
                             unsigned int num_offsets, struct gpiod_line_bulk *bulk);
int gpiod_chip_get_all_lines(struct gpiod_chip *chip, struct gpiod_line_bulk *bulk);
int gpiod_chip_find_lines   (struct gpiod_chip *chip, const char **names,  // NULL-terminated
                             struct gpiod_line_bulk *bulk);

// Convenience: open chip + get line in one call
// Caller must close the chip when done (via gpiod_line_get_chip + gpiod_chip_close)
struct gpiod_line *gpiod_line_get (const char *device, unsigned int offset);
struct gpiod_line *gpiod_line_find(const char *name);   // searches all chips
void               gpiod_line_close_chip(struct gpiod_line *line); // close owning chip
struct gpiod_chip *gpiod_line_get_chip  (struct gpiod_line *line); // get owning chip handle
```

---

## Line Request — Single Line

```c
// Convenience wrappers (most common)
int gpiod_line_request_input (struct gpiod_line *line, const char *consumer);
int gpiod_line_request_output(struct gpiod_line *line, const char *consumer, int default_val);

// With extra flags
int gpiod_line_request_input_flags (struct gpiod_line *line, const char *consumer, int flags);
int gpiod_line_request_output_flags(struct gpiod_line *line, const char *consumer,
                                    int flags, int default_val);

// General form using config struct
int gpiod_line_request(struct gpiod_line *line,
                       const struct gpiod_line_request_config *config,
                       int default_val);

// Event request variants
int gpiod_line_request_rising_edge_events (struct gpiod_line *line, const char *consumer);
int gpiod_line_request_falling_edge_events(struct gpiod_line *line, const char *consumer);
int gpiod_line_request_both_edges_events  (struct gpiod_line *line, const char *consumer);

int gpiod_line_request_rising_edge_events_flags (struct gpiod_line *line, const char *consumer, int flags);
int gpiod_line_request_falling_edge_events_flags(struct gpiod_line *line, const char *consumer, int flags);
int gpiod_line_request_both_edges_events_flags  (struct gpiod_line *line, const char *consumer, int flags);
```

---

## Line Request — Bulk

```c
// Convenience wrappers
int gpiod_line_request_bulk_input (struct gpiod_line_bulk *bulk, const char *consumer);
int gpiod_line_request_bulk_output(struct gpiod_line_bulk *bulk, const char *consumer,
                                   const int *default_vals);

// With extra flags
int gpiod_line_request_bulk_input_flags (struct gpiod_line_bulk *bulk, const char *consumer, int flags);
int gpiod_line_request_bulk_output_flags(struct gpiod_line_bulk *bulk, const char *consumer,
                                         int flags, const int *default_vals);

// General form using config struct
int gpiod_line_request_bulk(struct gpiod_line_bulk *bulk,
                            const struct gpiod_line_request_config *config,
                            const int *default_vals);

// Event request variants (and their _flags counterparts)
int gpiod_line_request_bulk_rising_edge_events  (struct gpiod_line_bulk *bulk, const char *consumer);
int gpiod_line_request_bulk_falling_edge_events (struct gpiod_line_bulk *bulk, const char *consumer);
int gpiod_line_request_bulk_both_edges_events   (struct gpiod_line_bulk *bulk, const char *consumer);
int gpiod_line_request_bulk_rising_edge_events_flags (struct gpiod_line_bulk *bulk, const char *consumer, int flags);
int gpiod_line_request_bulk_falling_edge_events_flags(struct gpiod_line_bulk *bulk, const char *consumer, int flags);
int gpiod_line_request_bulk_both_edges_events_flags  (struct gpiod_line_bulk *bulk, const char *consumer, int flags);
```

### Bulk helper inlines

```c
void gpiod_line_bulk_init   (struct gpiod_line_bulk *bulk);       // sets num_lines = 0
void gpiod_line_bulk_add    (struct gpiod_line_bulk *bulk, struct gpiod_line *line);
struct gpiod_line *gpiod_line_bulk_get_line(struct gpiod_line_bulk *bulk, unsigned int offset);
unsigned int gpiod_line_bulk_num_lines     (struct gpiod_line_bulk *bulk);

// Iteration macros
gpiod_line_bulk_foreach_line    (bulk, line, lineptr)  // lineptr is struct gpiod_line **
gpiod_line_bulk_foreach_line_off(bulk, line, offset)   // offset is int/unsigned int
```

---

## Line Value Read / Write

```c
// Single line
int gpiod_line_get_value(struct gpiod_line *line);               // returns 0, 1, or -1 on error
int gpiod_line_set_value(struct gpiod_line *line, int value);    // returns 0 or -1

// Bulk (lines must have been requested together)
int gpiod_line_get_value_bulk(struct gpiod_line_bulk *bulk, int *values);
int gpiod_line_set_value_bulk(struct gpiod_line_bulk *bulk, const int *values); // NULL = all low
```

---

## Line Config Updates (post-request)

```c
// Update direction + flags + value
int gpiod_line_set_config     (struct gpiod_line *line, int direction, int flags, int value);
int gpiod_line_set_config_bulk(struct gpiod_line_bulk *bulk, int direction, int flags, const int *values);

// Flags only
int gpiod_line_set_flags     (struct gpiod_line *line, int flags);
int gpiod_line_set_flags_bulk(struct gpiod_line_bulk *bulk, int flags);

// Direction only
int gpiod_line_set_direction_input        (struct gpiod_line *line);
int gpiod_line_set_direction_input_bulk   (struct gpiod_line_bulk *bulk);
int gpiod_line_set_direction_output       (struct gpiod_line *line, int value);
int gpiod_line_set_direction_output_bulk  (struct gpiod_line_bulk *bulk, const int *values);
```

---

## Release

```c
void gpiod_line_release     (struct gpiod_line *line);
void gpiod_line_release_bulk(struct gpiod_line_bulk *bulk);  // lines must have been requested together

bool gpiod_line_is_requested(struct gpiod_line *line);   // true if we own it
bool gpiod_line_is_free     (struct gpiod_line *line);   // true if not owned by anyone

void gpiod_chip_close(struct gpiod_chip *chip);          // releases chip + all its lines
```

---

## Event Handling

```c
// Request (see Line Request — Single Line above for convenience wrappers)

// Wait / read
int gpiod_line_event_wait     (struct gpiod_line *line, const struct timespec *timeout);
// returns: 1 = event, 0 = timeout, -1 = error

int gpiod_line_event_wait_bulk(struct gpiod_line_bulk *bulk, const struct timespec *timeout,
                               struct gpiod_line_bulk *event_bulk); // event_bulk may be NULL
// returns: 1 = at least one event, 0 = timeout, -1 = error

int gpiod_line_event_read         (struct gpiod_line *line, struct gpiod_line_event *event);
int gpiod_line_event_read_multiple(struct gpiod_line *line, struct gpiod_line_event *events,
                                   unsigned int num_events);  // returns count or -1

// File descriptor access (for custom poll loops)
int gpiod_line_event_get_fd(struct gpiod_line *line);         // returns fd or -1

// Read directly from fd (after custom poll)
int gpiod_line_event_read_fd        (int fd, struct gpiod_line_event *event);
int gpiod_line_event_read_fd_multiple(int fd, struct gpiod_line_event *events,
                                      unsigned int num_events);
```

---

## Line Info

```c
unsigned int gpiod_line_offset      (struct gpiod_line *line);  // line number within chip
const char  *gpiod_line_name        (struct gpiod_line *line);  // NULL if unnamed
const char  *gpiod_line_consumer    (struct gpiod_line *line);  // NULL if not in use
int          gpiod_line_direction   (struct gpiod_line *line);  // GPIOD_LINE_DIRECTION_*
int          gpiod_line_active_state(struct gpiod_line *line);  // GPIOD_LINE_ACTIVE_STATE_*
int          gpiod_line_bias        (struct gpiod_line *line);  // GPIOD_LINE_BIAS_*
bool         gpiod_line_is_used     (struct gpiod_line *line);
bool         gpiod_line_is_open_drain  (struct gpiod_line *line);
bool         gpiod_line_is_open_source (struct gpiod_line *line);

// Re-read info from kernel (normally automatic after request)
int  gpiod_line_update(struct gpiod_line *line);  // returns 0 or -1
```

---

## Iterators

```c
// Chip iterator (scans /dev/ for gpiochipN devices)
struct gpiod_chip_iter *gpiod_chip_iter_new          (void);
void                    gpiod_chip_iter_free          (struct gpiod_chip_iter *iter); // closes last chip
void                    gpiod_chip_iter_free_noclose  (struct gpiod_chip_iter *iter);
struct gpiod_chip      *gpiod_chip_iter_next          (struct gpiod_chip_iter *iter); // closes prev chip
struct gpiod_chip      *gpiod_chip_iter_next_noclose  (struct gpiod_chip_iter *iter);

// Convenience foreach macros
gpiod_foreach_chip         (iter, chip)  // auto-closes each chip
gpiod_foreach_chip_noclose (iter, chip)  // caller closes each chip manually

// Line iterator
struct gpiod_line_iter *gpiod_line_iter_new (struct gpiod_chip *chip);
void                    gpiod_line_iter_free(struct gpiod_line_iter *iter);
struct gpiod_line      *gpiod_line_iter_next(struct gpiod_line_iter *iter); // NULL when done

gpiod_foreach_line(iter, line)  // iterates all lines on a chip
```

---

## Enums & Constants

### Directions

| Constant | Value | Meaning |
|---|---|---|
| `GPIOD_LINE_DIRECTION_INPUT` | 1 | Line configured as input |
| `GPIOD_LINE_DIRECTION_OUTPUT` | 2 | Line configured as output |

### Active State

| Constant | Value | Meaning |
|---|---|---|
| `GPIOD_LINE_ACTIVE_STATE_HIGH` | 1 | Active-high (default) |
| `GPIOD_LINE_ACTIVE_STATE_LOW` | 2 | Active-low |

### Bias

| Constant | Value | Meaning |
|---|---|---|
| `GPIOD_LINE_BIAS_AS_IS` | 1 | Unknown / unchanged |
| `GPIOD_LINE_BIAS_DISABLE` | 2 | No pull resistor |
| `GPIOD_LINE_BIAS_PULL_UP` | 3 | Pull-up enabled |
| `GPIOD_LINE_BIAS_PULL_DOWN` | 4 | Pull-down enabled |

### Request Types (`request_type` field)

| Constant | Value | Meaning |
|---|---|---|
| `GPIOD_LINE_REQUEST_DIRECTION_AS_IS` | 1 | Don't change direction |
| `GPIOD_LINE_REQUEST_DIRECTION_INPUT` | 2 | Set as input |
| `GPIOD_LINE_REQUEST_DIRECTION_OUTPUT` | 3 | Set as output |
| `GPIOD_LINE_REQUEST_EVENT_FALLING_EDGE` | 4 | Monitor falling edges |
| `GPIOD_LINE_REQUEST_EVENT_RISING_EDGE` | 5 | Monitor rising edges |
| `GPIOD_LINE_REQUEST_EVENT_BOTH_EDGES` | 6 | Monitor both edges |

### Request Flags (OR together)

| Constant | Bit | Meaning |
|---|---|---|
| `GPIOD_LINE_REQUEST_FLAG_OPEN_DRAIN` | bit 0 | Open-drain output |
| `GPIOD_LINE_REQUEST_FLAG_OPEN_SOURCE` | bit 1 | Open-source output |
| `GPIOD_LINE_REQUEST_FLAG_ACTIVE_LOW` | bit 2 | Invert logic |
| `GPIOD_LINE_REQUEST_FLAG_BIAS_DISABLE` | bit 3 | Disable bias |
| `GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_DOWN` | bit 4 | Enable pull-down |
| `GPIOD_LINE_REQUEST_FLAG_BIAS_PULL_UP` | bit 5 | Enable pull-up |

### Event Types (`gpiod_line_event.event_type`)

| Constant | Value | Meaning |
|---|---|---|
| `GPIOD_LINE_EVENT_RISING_EDGE` | 1 | Rising edge occurred |
| `GPIOD_LINE_EVENT_FALLING_EDGE` | 2 | Falling edge occurred |

### High-level (ctxless) flags

| Constant | Bit | Meaning |
|---|---|---|
| `GPIOD_CTXLESS_FLAG_OPEN_DRAIN` | bit 0 | Open-drain |
| `GPIOD_CTXLESS_FLAG_OPEN_SOURCE` | bit 1 | Open-source |
| `GPIOD_CTXLESS_FLAG_BIAS_DISABLE` | bit 2 | Disable bias |
| `GPIOD_CTXLESS_FLAG_BIAS_PULL_DOWN` | bit 3 | Pull-down |
| `GPIOD_CTXLESS_FLAG_BIAS_PULL_UP` | bit 4 | Pull-up |

---

## CLI Tools

Quick reference for manual testing directly on the Pi.

| Tool | Purpose | Key options |
|---|---|---|
| `gpiodetect` | List all GPIO chips | — |
| `gpioinfo [chip]` | Show all lines and their state | — |
| `gpioget <chip> <offset>...` | Read line values | `--active-low`, `--bias=pull-up\|pull-down\|disable` |
| `gpioset <chip> <offset>=<val>...` | Set line values (holds until exit) | `--mode=exit\|wait\|time\|signal`, `--bias=`, `--drive=`, `--background` |
| `gpiomon <chip> <offset>...` | Monitor edge events | `--rising-edge`, `--falling-edge`, `--num-events=N`, `--format=<fmt>` |
| `gpiofind <name>` | Find chip + offset by line name | — |

`<chip>` accepts a path (`/dev/gpiochip0`), name (`gpiochip0`), number (`0`), or label.

---

## High-Level (ctxless) API

One-shot helpers that open, use, and close a chip internally — no resource management needed.

```c
// Read single line
int gpiod_ctxless_get_value(const char *device, unsigned int offset,
                            bool active_low, const char *consumer);

// Read multiple lines
int gpiod_ctxless_get_value_multiple(const char *device, const unsigned int *offsets,
                                     int *values, unsigned int num_lines,
                                     bool active_low, const char *consumer);

// Set single line (cb called after set; can be NULL)
int gpiod_ctxless_set_value(const char *device, unsigned int offset, int value,
                            bool active_low, const char *consumer,
                            gpiod_ctxless_set_value_cb cb, void *data);

// Set multiple lines
int gpiod_ctxless_set_value_multiple(const char *device, const unsigned int *offsets,
                                     const int *values, unsigned int num_lines,
                                     bool active_low, const char *consumer,
                                     gpiod_ctxless_set_value_cb cb, void *data);

// Event monitor (single line)
int gpiod_ctxless_event_monitor(const char *device, int event_type, unsigned int offset,
                                bool active_low, const char *consumer,
                                const struct timespec *timeout,
                                gpiod_ctxless_event_poll_cb poll_cb,   // NULL = ppoll default
                                gpiod_ctxless_event_handle_cb event_cb,
                                void *data);

// Event monitor (multiple lines)
int gpiod_ctxless_event_monitor_multiple(const char *device, int event_type,
                                         const unsigned int *offsets, unsigned int num_lines,
                                         bool active_low, const char *consumer,
                                         const struct timespec *timeout,
                                         gpiod_ctxless_event_poll_cb poll_cb,
                                         gpiod_ctxless_event_handle_cb event_cb,
                                         void *data);

// Find chip name + offset by line name
int gpiod_ctxless_find_line(const char *name, char *chipname, size_t chipname_size,
                            unsigned int *offset);  // returns 1=found, 0=not found, -1=error
```

`_ext` variants of all ctxless functions exist and accept an additional `int flags` parameter.

---

## Misc

```c
const char *gpiod_version_string(void);  // e.g. "1.6.3"
```

---

## Typical Usage Pattern

```c
#include <gpiod.h>
#include <stdio.h>
#include <unistd.h>

#define CHIP    "gpiochip0"
#define RED_OFF  17   // BCM offset for red LED
#define AMB_OFF  27   // BCM offset for amber LED
#define GRN_OFF  22   // BCM offset for green LED

int main(void)
{
    struct gpiod_chip *chip;
    struct gpiod_line *red, *amber, *green;

    chip  = gpiod_chip_open_by_name(CHIP);
    red   = gpiod_chip_get_line(chip, RED_OFF);
    amber = gpiod_chip_get_line(chip, AMB_OFF);
    green = gpiod_chip_get_line(chip, GRN_OFF);

    gpiod_line_request_output(red,   "traffic-lights", 0);
    gpiod_line_request_output(amber, "traffic-lights", 0);
    gpiod_line_request_output(green, "traffic-lights", 0);

    // Green
    gpiod_line_set_value(green, 1);
    sleep(5);

    // Amber
    gpiod_line_set_value(green, 0);
    gpiod_line_set_value(amber, 1);
    sleep(2);

    // Red
    gpiod_line_set_value(amber, 0);
    gpiod_line_set_value(red, 1);
    sleep(5);

    gpiod_line_release(red);
    gpiod_line_release(amber);
    gpiod_line_release(green);
    gpiod_chip_close(chip);
    return 0;
}
```

Compile: `gcc -o prog prog.c -lgpiod`

**Note:** BCM offsets are the GPIO numbers used by the kernel (same as `gpioinfo` shows). They correspond directly to the `offset` parameter in libgpiod — no pin-numbering translation needed (unlike WiringPi).
