import { ChangeEvent } from "react";
import { useRouter } from "next/router";

export const LanguageSelector = () => {
  const { locale } = useRouter();

  const onLanguageChange = (e: ChangeEvent<HTMLSelectElement>) => {
    const newLocale = e.target.value;
    window.location.assign(
      window.location.href.replace(locale || ``, newLocale),
    );
    const date = new Date();
    date.setMonth(date.getMonth() + 12);
    const expires = "expires=" + date.toUTCString();
    document.cookie = `LOCALE=${newLocale}; path=/; ${expires}`;
  };

  return (
    <div className={"p-14"}>
      Language:
      <select
        onChange={onLanguageChange}
        value={locale}
        className={
          "p-4 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500"
        }
      >
        <option value={"en"}>English</option>
        <option value={"it"}>Italiano</option>
      </select>
    </div>
  );
};
