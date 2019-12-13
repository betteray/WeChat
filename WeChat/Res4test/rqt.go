package crypt

import (
	"bytes"
	"encoding/hex"
)

var rqtKey = map[int]string{
	1: "6a664d5d537c253f736e48273a295e4f",
}

func CalRqtData(data []byte) int {
	md5 := Md5ByByte(data)
	return SignRqtBufByAutoChosenKey(1, md5, 1)
}
func SignRqtBufByAutoChosenKey(key int, md5 string, r1 int) int {
	keyData := rqtKey[1]
	pixels, _ := hex.DecodeString(keyData)
	buffer := bytes.Buffer{}
	block := make([]byte, 0)
	block = append(pixels, make([]byte, 48)...)
	for i := 0; i < len(block); i++ {
		block[i] ^= 0x36
	}
	buffer.Write(block)
	buffer.Write([]byte(md5))
	tmp := buffer.Bytes()

	block = make([]byte, 0)
	block = append(pixels, make([]byte, 48)...)
	for i := 0; i < len(block); i++ {
		block[i] ^= 0x5c
	}
	buffer = bytes.Buffer{}
	buffer.Write(block)
	buffer.Write(Sha1(tmp))
	tmp = buffer.Bytes()
	sha := Sha1(tmp)
	var t1, t2, t3 int
	for i := 2; i < len(sha); i++ {
		v1 := sha[i-2] & 0xff
		v2 := sha[i-1] & 0xff
		v3 := sha[i] & 0xff
		t1 = 0x83*t1 + int(v1)
		t2 = 0x83*t2 + int(v2)
		t3 = 0x83*t3 + int(v3)
	}
	r3 := t1 & 0x7f
	r4 := (t3 << 16) & 0x7f0000
	r5 := (t2 << 8) & 0x7f00
	return r3 | r4 | r5 | ((r1<<5 | key&0x1f) << 24)
}
