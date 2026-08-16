It looks like the RLE segment has been padded out to 786433 bytes even though:

> Each RLE segment must be an even number of bytes or padded at its end with zero to make it even.

The solution would be to only raise an exception if the segment is shorter than expected and trim excess padding.

There's no simple workaround, but you should be able to do:
```python
from pydicom import dcmread
from pydicom.pixel_data_handlers import rle_handler
from pydicom.pixel_data_handlers.rle_handler import _parse_rle_header, _rle_decode_segment

def frame_decoder(data, rows, columns, nr_samples, nr_bits, segment_order = '>'):
    if nr_bits % 8:
        raise NotImplementedError(
            "Unable to decode RLE encoded pixel data with a (0028,0100) "
            f"'Bits Allocated' value of {nr_bits}"
        )

    offsets = _parse_rle_header(data[:64])
    nr_segments = len(offsets)

    bytes_per_sample = nr_bits // 8
    if nr_segments != nr_samples * bytes_per_sample:
        raise ValueError(
            "The number of RLE segments in the pixel data doesn't match the "
            f"expected amount ({nr_segments} vs. "
            f"{nr_samples * bytes_per_sample} segments)"
        )

    offsets.append(len(data))

    decoded = bytearray(rows * columns * nr_samples * bytes_per_sample)

    stride = bytes_per_sample * rows * columns
    for sample_number in range(nr_samples):
        le_gen = range(bytes_per_sample)
        byte_offsets = le_gen if segment_order == '<' else reversed(le_gen)
        for byte_offset in byte_offsets:
            ii = sample_number * bytes_per_sample + byte_offset
            segment = _rle_decode_segment(data[offsets[ii]:offsets[ii + 1]])
            if len(segment) < rows * columns:
                raise ValueError(
                    "The amount of decoded RLE segment data doesn't match the "
                    f"expected amount ({len(segment)} vs. "
                    f"{rows * columns} bytes)"
                )

            if segment_order == '>':
                byte_offset = bytes_per_sample - byte_offset - 1

            start = byte_offset + (sample_number * stride)
            decoded[start:start + stride:bytes_per_sample] = segment[:rows * columns]

    return decoded

rle_handler._rle_decode_frame = frame_decoder

ds = dcmread('path/to/file.dcm')
ds.decompress('rle')
arr = ds.pixel_array
```
