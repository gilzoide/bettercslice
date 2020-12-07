/++
 + TODO: doc
 +/
struct Slice(T)
{
    T* ptr;
    size_t length;

    this(inout(T)* ptr, size_t length) inout
    {
        this(ptr[0..length]);
    }
    this(inout(T)[] slice) inout
    {
        this.ptr = slice.ptr;
        this.length = slice.length;
    }
    this(inout(void)* ptr, size_t bytesLength) inout
    {
        this(ptr[0..bytesLength]);
    }
    this(inout(void)[] slice) inout
    {
        this(cast(inout(T)[]) slice);
    }
    this(size_t N)(inout(T)[N] array) inout
    {
        this.ptr = array.ptr;
        this.length = N;
    }

    invariant
    {
        assert((ptr == null && length == 0) || ptr != null);
    }

    struct IndexRange
    {
        size_t from, to;
    }

    inout(T)[] dSlice() inout
    {
        return ptr[0..length];
    }

    alias opCast(U : T[]) = dSlice;
    bool opCast(U : bool)() const
    {
        return !empty;
    }

    @property size_t bytesLength() const
    {
        return length * T.sizeof;
    }

    // InputRange
    @property ref inout(T) front() inout
    {
        return ptr[0];
    }

    void popFront()
    {
        ptr += 1;
        length -= 1;
    }

    @property bool empty() const
    {
        return length == 0;
    }

    // ForwardRange
    inout(Slice) save() inout
    {
        return this;
    }

    // BidirectionalRange
    @property ref inout(T) back() inout
    {
        return ptr[length - 1];
    }

    void popBack()
    {
        length -= 1;
    }

    // RandomAccessFinite
    ref inout(T) opIndex(size_t i) inout
    {
        return ptr[i];
    }

    inout(Slice) opIndex(const IndexRange r) inout
    {
        return typeof(return)(ptr + r.from, r.to - r.from);
    }

    size_t opDollar(size_t pos : 0)() const
    {
        return length;
    }

    inout(Slice) opIndex() inout
    {
        return this;
    }

    IndexRange opSlice(size_t pos : 0)(size_t from, size_t to)
    {
        typeof(return) range = {
            from: from,
            to: to,
        };
        return range;
    }

    // InputAssignable
    @property void front(const T value)
    {
        ptr[0] = value;
    }

    // BidirectionalAssignable
    @property void back(const T value)
    {
        ptr[length - 1] = value;
    }

    // RandomFiniteAssignable
    void opIndexAssign(const T value, size_t index)
    {
        ptr[index] = value;
    }
}

unittest
{
    import std.range.primitives;

    alias IntSlice = Slice!int;
    assert(isInputRange!IntSlice);
    assert(isForwardRange!IntSlice);
    assert(isBidirectionalRange!IntSlice);
    assert(isRandomAccessRange!IntSlice);

    assert(hasMobileElements!IntSlice);
    assert(is(ElementType!IntSlice == int));
    assert(hasSwappableElements!IntSlice);
    assert(hasAssignableElements!IntSlice);
    assert(hasLvalueElements!IntSlice);
    assert(hasLength!IntSlice);
    assert(!isInfinite!IntSlice);
    assert(hasSlicing!IntSlice);
}

unittest
{
    import std.algorithm;
    import std.stdio;
    import std.range;

    int[5] array = [1, 2, 3, 4, 5];

    auto s = Slice!int(array);
    Slice!int s2 = [1, 2, 3, 4, 5];
    assert(s.dSlice == array);
    foreach (i, value; s.enumerate)
    {
        assert(value == array[i]);
    }

    assert(s.dSlice.retro == array[].retro);
    foreach (i, value; s.retro.enumerate)
    {
        assert(value == array[$ - 1 - i]);
    }

    assert(__traits(compiles, cast(int[]) s));

    assert(cast(bool) s);
    writeln(s.stride(3));

    writeln("");
    s.filter!(x => x % 2 == 1).writeln;

    alias StringSlice = Slice!string;
}

unittest
{
    Slice!int n;
    assert(n.empty);
    assert(!n);
}
