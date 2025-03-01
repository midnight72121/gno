package hd

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/gnolang/gno/pkgs/crypto"
	"github.com/gnolang/gno/pkgs/crypto/bip39"
	"github.com/gnolang/gno/pkgs/crypto/secp256k1"
)

type addrData struct {
	Mnemonic string
	Master   string
	Seed     string
	Priv     string
	Pub      string
	Addr     string
}

func initFundraiserTestVectors(t *testing.T) []addrData {
	// NOTE: atom fundraiser address
	// var hdPath string = "m/44'/118'/0'/0/0"
	var hdToAddrTable []addrData

	b, err := os.ReadFile("test.json")
	if err != nil {
		t.Fatalf("could not read fundraiser test vector file (test.json): %s", err)
	}

	err = json.Unmarshal(b, &hdToAddrTable)
	if err != nil {
		t.Fatalf("could not decode test vectors (test.json): %s", err)
	}
	return hdToAddrTable
}

func TestFundraiserCompatibility(t *testing.T) {
	hdToAddrTable := initFundraiserTestVectors(t)

	for i, d := range hdToAddrTable {
		privB, _ := hex.DecodeString(d.Priv)
		pubB, _ := hex.DecodeString(d.Pub)
		addrB, _ := hex.DecodeString(d.Addr)
		seedB, _ := hex.DecodeString(d.Seed)
		masterB, _ := hex.DecodeString(d.Master)

		seed := bip39.NewSeed(d.Mnemonic, "")

		t.Log("================================")
		t.Logf("ROUND: %d MNEMONIC: %s", i, d.Mnemonic)

		master, ch := ComputeMastersFromSeed(seed)
		priv, err := DerivePrivateKeyForPath(master, ch, "44'/118'/0'/0/0")
		require.NoError(t, err)
		pub := secp256k1.PrivKeySecp256k1(priv).PubKey()

		t.Log("\tNODEJS GOLANG\n")
		t.Logf("SEED \t%X %X\n", seedB, seed)
		t.Logf("MSTR \t%X %X\n", masterB, master)
		t.Logf("PRIV \t%X %X\n", privB, priv)
		t.Logf("PUB  \t%X %X\n", pubB, pub)

		require.Equal(t, seedB, seed)
		require.Equal(t, master[:], masterB, fmt.Sprintf("Expected masters to match for %d", i))
		require.Equal(t, priv[:], privB, "Expected priv keys to match")
		var pubBFixed [33]byte
		copy(pubBFixed[:], pubB)
		require.Equal(t, pub, secp256k1.PubKeySecp256k1(pubBFixed), fmt.Sprintf("Expected pub keys to match for %d", i))

		addr := pub.Address()
		t.Logf("ADDR  \t%X %X\n", addrB, addr)
		require.Equal(t, addr, crypto.AddressFromBytes(addrB), fmt.Sprintf("Expected addresses to match %d", i))

	}
}
