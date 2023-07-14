import { Inter } from "next/font/google";
import { GetStaticProps } from "next";
import React from "react";
import { LanguageSelector } from "@/components/LanguageSelector";

const inter = Inter({ subsets: ["latin"] });

export const getStaticProps: GetStaticProps = async () => {
  console.log(`Getting props for ISR Page ...................`);
  return { props: { time: new Date().toLocaleString() }, revalidate: 20 };
};

export default function Home({ time }: { time: string }) {
  return (
    <main
      className={`flex min-h-screen flex-col items-center p-24 ${inter.className}`}
    >
      <LanguageSelector />
      <div className="z-10 w-full max-w-5xl items-center justify-between">
        <p className="pb-24 fixed left-0 top-0 text-2xl flex w-full justify-center border-b border-gray-300 bg-gradient-to-b from-zinc-200 pt-8 backdrop-blur-2xl dark:border-neutral-800 dark:bg-zinc-800/30 dark:from-inherit lg:static lg:w-auto  lg:rounded-xl lg:border lg:bg-gray-200 lg:p-4 lg:dark:bg-zinc-800/30">
          Static Page - Generated at : {time}
        </p>
      </div>
    </main>
  );
}
