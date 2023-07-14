import Link from "next/link";

export const Header = () => {
  return (
    <header className={"flex justify-between w-1/3 mx-auto pt-12"}>
      <Link href={"/"} className={"hover:underline"}>
        Static Page
      </Link>
      <Link href={"/ssr"} className={"hover:underline"}>
        SSR Page
      </Link>
      <Link href={"/isr"} className={"hover:underline"}>
        ISR Page
      </Link>
    </header>
  );
};
