import { ImageResponse } from "next/og";
import { readFile } from "fs/promises";
import { join } from "path";

export const alt = "Less — turn your iPhone into a dumbphone";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image() {
  const screenshot = await readFile(
    join(process.cwd(), "public/screens/home-widgets.jpg")
  );
  const src = `data:image/jpeg;base64,${screenshot.toString("base64")}`;
  const mark = await readFile(join(process.cwd(), "public/mark.png"));
  const markSrc = `data:image/png;base64,${mark.toString("base64")}`;

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          background: "#000",
          padding: "0 80px",
        }}
      >
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            flex: 1,
            paddingRight: 60,
          }}
        >
          <img
            src={markSrc}
            width={96}
            height={96}
            style={{
              borderRadius: 24,
              border: "1px solid #2a2a2a",
            }}
          />
          <div
            style={{
              marginTop: 48,
              color: "#fff",
              fontSize: 76,
              fontWeight: 700,
              lineHeight: 1.05,
            }}
          >
            Your phone, minus the noise.
          </div>
          <div
            style={{
              marginTop: 28,
              color: "#8a8a8a",
              fontSize: 32,
              lineHeight: 1.4,
            }}
          >
            Less turns your iPhone into a minimal dumbphone.
          </div>
          <div style={{ marginTop: 36, color: "#5a5a5a", fontSize: 26 }}>
            Free beta · getless.vercel.app
          </div>
        </div>
        <img
          src={src}
          width={262}
          height={570}
          style={{
            borderRadius: 36,
            border: "2px solid #2a2a2a",
            objectFit: "cover",
          }}
        />
      </div>
    ),
    size
  );
}
