import { Inter } from "next/font/google";
import { GetServerSideProps } from "next";
import React from "react";
import { LanguageSelector } from "@/components/LanguageSelector";

const inter = Inter({ subsets: ["latin"] });

export const getServerSideProps: GetServerSideProps<{ time: string }> = async ({
  res,
}) => {
  console.log(`Getting props for SSR Page ...................`);

  // This value is considered fresh for ten seconds (s-maxage=10).
  // If a request is repeated within the next 10 seconds, the previously
  // cached value will still be fresh. If the request is repeated before 59 seconds,
  // the cached value will be stale but still render (stale-while-revalidate=59).
  // In the background, a revalidation request will be made to populate the cache
  // with a fresh value. If you refresh the page, you will see the new value.

  // res.setHeader(
  //   "Cache-Control",
  //   "public, s-maxage=10, stale-while-revalidate=59",
  // );
  return { props: { time: new Date().toLocaleString() } };
};

export default function Home({ time }: { time: string }) {
  return (
    <main
      className={`flex min-h-screen flex-col items-center p-24 ${inter.className}`}
    >
      <LanguageSelector />
      <div className="z-10 w-full max-w-5xl items-center justify-between">
        <p className="pb-24 fixed left-0 top-0 text-2xl flex w-full justify-center border-b border-gray-300 bg-gradient-to-b from-zinc-200 pt-8 backdrop-blur-2xl dark:border-neutral-800 dark:bg-zinc-800/30 dark:from-inherit lg:static lg:w-auto  lg:rounded-xl lg:border lg:bg-gray-200 lg:p-4 lg:dark:bg-zinc-800/30">
          Server Side Rendered Page - Generated at : {time}
        </p>
      </div>
    </main>
  );
}
