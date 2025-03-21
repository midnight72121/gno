package gnoblog

import (
	"std"
	"strings"
	"testing"
)

func TestPackage(t *testing.T) {
	std.TestSetOrigCaller(std.Address("g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq"))

	author := std.GetOrigCaller()

	// by default, no posts.
	{
		got := Render("")
		expected := `
# Gnoland's Blog

No posts.
`
		assertMDEquals(t, got, expected)
	}

	// create two posts, list post.
	{
		ModAddPost("slug1", "title1", "body1", "tag1,tag2")
		ModAddPost("slug2", "title2", "body2", "tag1,tag3")
		got := Render("")
		expected := `
# Gnoland's Blog

## [&#9656; title1](/r/gnoland/blog:p/slug1)

## [&#9656; title2](/r/gnoland/blog:p/slug2)
`
		assertMDEquals(t, got, expected)
	}

	// view post.
	{
		got := Render("p/slug2")
		expected := `
# [Gnoland's Blog](/r/gnoland/blog:) / p / title2

body2

[#tag1](/r/gnoland/blog:t/tag1) [#tag3](/r/gnoland/blog:t/tag3)

by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC
`
		assertMDEquals(t, got, expected)
	}

	// list by tags.
	{
		got := Render("t/invalid")
		expected := "# [Gnoland's Blog](/r/gnoland/blog:) / t / invalid\n\nNo posts."
		assertMDEquals(t, got, expected)

		got = Render("t/tag2")
		expected = `
# [Gnoland's Blog](/r/gnoland/blog:) / t / tag2

## [&#9656; title1](/r/gnoland/blog:p/slug1)
`
		assertMDEquals(t, got, expected)
	}

	// add comments.
	{
		AddComment("slug1", "comment1")
		AddComment("slug2", "comment2")
		AddComment("slug1", "comment3")
		AddComment("slug2", "comment4")
		AddComment("slug1", "comment5")
		got := Render("p/slug2")
		expected := `
# [Gnoland's Blog](/r/gnoland/blog:) / p / title2

body2

[#tag1](/r/gnoland/blog:t/tag1) [#tag3](/r/gnoland/blog:t/tag3)

by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC

#### by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC
comment4

#### by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC
comment2
`
		assertMDEquals(t, got, expected)
	}

	// edit post.
	{
		ModEditPost("slug2", "title2++", "body2++", "tag1,tag4")
		got := Render("p/slug2")
		expected := `
# [Gnoland's Blog](/r/gnoland/blog:) / p / title2++

body2++

[#tag1](/r/gnoland/blog:t/tag1) [#tag4](/r/gnoland/blog:t/tag4)

by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC

#### by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC
comment4

#### by g1u7y667z64x2h7vc6fmpcprgey4ck233jaww9zq on 2009-02-13 11:31pm UTC
comment2
`
		assertMDEquals(t, got, expected)
	}

	// TODO: pagination.
	// TODO: ?format=...

	// all 404s
	{
		notFoundPaths := []string{
			"p/slug3",
			"p",
			"p/",
			"x/x",
			"t",
			"t/",
			"/",
			"p/slug1/",
		}
		for _, notFoundPath := range notFoundPaths {
			got := Render(notFoundPath)
			expected := "404"
			if got != expected {
				t.Errorf("path %q: expected %q, got %q.", notFoundPath, expected, got)
			}
		}
	}
}

func assertMDEquals(t *testing.T, got, expected string) {
	t.Helper()
	expected = strings.TrimSpace(expected)
	got = strings.TrimSpace(got)
	if expected != got {
		t.Errorf("invalid render output.\nexpected %q.\ngot      %q.", expected, got)
	}
}
