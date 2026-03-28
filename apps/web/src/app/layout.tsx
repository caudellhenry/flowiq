import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "FlowIQ",
  description: "AI-powered document processing and workflow automation for SMEs",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
