package hashing

type Member string

func (m Member) String() string {
	return string(m)
}

type hasher struct {
}
