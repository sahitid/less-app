import { get, list, put } from "@vercel/blob";
import { createHash } from "crypto";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

export async function POST(request: Request) {
  let body: { name?: string; email?: string; company?: string };
  try {
    body = await request.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  // Honeypot: real users never fill this hidden field.
  if (body.company) {
    return Response.json({ ok: true });
  }

  const name = (body.name ?? "").trim().slice(0, 100);
  const email = (body.email ?? "").trim().toLowerCase().slice(0, 200);

  if (!name) {
    return Response.json({ error: "Please enter your name" }, { status: 400 });
  }
  if (!EMAIL_RE.test(email)) {
    return Response.json({ error: "Please enter a valid email" }, { status: 400 });
  }

  // One blob per email so duplicate signups just update in place.
  const key = createHash("sha256").update(email).digest("hex").slice(0, 32);
  await put(
    `waitlist/${key}.json`,
    JSON.stringify({ name, email, joinedAt: new Date().toISOString() }),
    {
      access: "private",
      contentType: "application/json",
      addRandomSuffix: false,
      allowOverwrite: true,
    }
  );

  return Response.json({ ok: true });
}

// CSV export for the site owner: /api/waitlist?key=<WAITLIST_SECRET>
export async function GET(request: Request) {
  const url = new URL(request.url);
  if (!process.env.WAITLIST_SECRET || url.searchParams.get("key") !== process.env.WAITLIST_SECRET) {
    return new Response("Not found", { status: 404 });
  }

  const { blobs } = await list({ prefix: "waitlist/" });
  const rows: { name: string; email: string; joinedAt: string }[] = [];
  for (const blob of blobs) {
    try {
      const result = await get(blob.pathname, { access: "private" });
      if (result?.statusCode === 200) {
        rows.push(JSON.parse(await new Response(result.stream).text()));
      }
    } catch {
      // skip unreadable entries
    }
  }
  rows.sort((a, b) => a.joinedAt.localeCompare(b.joinedAt));

  const esc = (s: string) => `"${(s ?? "").replaceAll('"', '""')}"`;
  const csv = [
    "Name,Email,Joined",
    ...rows.map((r) => [esc(r.name), esc(r.email), esc(r.joinedAt)].join(",")),
  ].join("\n");

  return new Response(csv, {
    headers: {
      "content-type": "text/csv; charset=utf-8",
      "content-disposition": 'attachment; filename="less-waitlist.csv"',
    },
  });
}
