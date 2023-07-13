import {Inter} from 'next/font/google'
import {createClient, EntryFieldTypes} from "contentful";
import {GetStaticProps} from "next";
import React from "react";
import {useRouter} from "next/router";

const inter = Inter({subsets: ['latin']})

type IntroFields = {
    id: EntryFieldTypes.Text,
    title: EntryFieldTypes.Text,
    description: EntryFieldTypes.RichText
}

type Intro = {
    contentTypeId: `intro`,
    fields: IntroFields
}

const contentful = createClient({
    space: `hq4skgadvikw`,
    accessToken: process.env.CONTENTFUL_TOKEN!,
    environment: `master`
});

export const getStaticProps: GetStaticProps = async (context) => {
    console.log(`Getting props ...................`);
    const entries = await contentful.getEntries<Intro>({
        content_type: `intro`,
        locale: context.locale === `default` ? `en` : context.locale
    });
    const intros = entries.items.map(entry => ({
        id: entry.fields.id as string,
        title: entry.fields.title as string,
    }));

    return {props: {intros}, revalidate: 20}
}

export default function Home({intros}: { intros: { id: string, title: string }[] }) {
    const {locale} = useRouter();
    return (
        <main
            className={`flex min-h-screen flex-col items-center p-24 ${inter.className}`}
        >
            <div>
                Language:
                <select onChange={(e) => {
                    const newLocale = e.target.value;
                    window.location.assign(window.location.href.replace(locale || ``, newLocale));
                    const date = new Date()
                    date.setMonth(date.getMonth() + 12)
                    const expires = 'expires=' + date.toUTCString()
                    document.cookie = `LOCALE=${newLocale}; path=/; ${expires}`
                }} value={locale} className={"text-black"}>
                    <option value={"en"}>English</option>
                    <option value={"it"}>Italino</option>
                </select>
            </div>
            <div className="z-10 w-full max-w-5xl items-center justify-between font-mono text-sm lg:flex pb-24">
                <p className="fixed left-0 top-0 flex w-full justify-center border-b border-gray-300 bg-gradient-to-b from-zinc-200 pb-6 pt-8 backdrop-blur-2xl dark:border-neutral-800 dark:bg-zinc-800/30 dark:from-inherit lg:static lg:w-auto  lg:rounded-xl lg:border lg:bg-gray-200 lg:p-4 lg:dark:bg-zinc-800/30">
                    This is a sample app created for Unfold UI demo
                </p>
            </div>
            <div className="z-10 w-full max-w-5xl items-center justify-between">
                <p className="pb-24 fixed left-0 top-0 text-2xl flex w-full justify-center border-b border-gray-300 bg-gradient-to-b from-zinc-200 pt-8 backdrop-blur-2xl dark:border-neutral-800 dark:bg-zinc-800/30 dark:from-inherit lg:static lg:w-auto  lg:rounded-xl lg:border lg:bg-gray-200 lg:p-4 lg:dark:bg-zinc-800/30">
                    Data coming from content system
                </p>
                {intros.map((intro, index) => {
                    return <div key={intro.id} className="py-5">
                        <p className="text-xl">
                            {index + 1}. {intro.id}: {intro.title}
                        </p>
                    </div>
                })}
            </div>
        </main>
    )
}
