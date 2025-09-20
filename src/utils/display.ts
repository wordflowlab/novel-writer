import chalk from 'chalk';

export function displayBanner(): void {
  const banner = `
╔═══════════════════════════════════════╗
║                                       ║
║     📚  Novel Writer  📝              ║
║                                       ║
║     AI 驱动的中文小说创作工具        ║
║                                       ║
╚═══════════════════════════════════════╝
`;

  console.log(chalk.cyan(banner));
  console.log(chalk.gray('  版本: 0.1.0 | 作者: Novel Writer Team\n'));
}

export function displayProgress(current: number, total: number, label: string = '进度'): void {
  const percentage = Math.round((current / total) * 100);
  const barLength = 30;
  const filledLength = Math.round((percentage / 100) * barLength);

  const bar = '█'.repeat(filledLength) + '░'.repeat(barLength - filledLength);

  console.log(`${label}: ${chalk.cyan(bar)} ${chalk.yellow(percentage + '%')} (${current}/${total})`);
}

export function displaySuccess(message: string): void {
  console.log(chalk.green('✓ ') + chalk.white(message));
}

export function displayError(message: string): void {
  console.log(chalk.red('✗ ') + chalk.white(message));
}

export function displayWarning(message: string): void {
  console.log(chalk.yellow('⚠ ') + chalk.white(message));
}

export function displayInfo(message: string): void {
  console.log(chalk.blue('ℹ ') + chalk.white(message));
}

export function displaySeparator(): void {
  console.log(chalk.gray('─'.repeat(50)));
}

export function displaySection(title: string): void {
  console.log('\n' + chalk.cyan.bold(`━━━ ${title} ━━━`));
}

export function formatWordCount(count: number): string {
  if (count < 10000) {
    return `${count}字`;
  }
  return `${(count / 10000).toFixed(1)}万字`;
}

export function formatDate(date: Date): string {
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
}

export function formatDateTime(date: Date): string {
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  });
}

export function displayTable(headers: string[], rows: string[][]): void {
  // 计算每列的最大宽度
  const colWidths = headers.map((header, index) => {
    const headerWidth = getDisplayWidth(header);
    const maxRowWidth = Math.max(
      ...rows.map(row => getDisplayWidth(row[index] || ''))
    );
    return Math.max(headerWidth, maxRowWidth) + 2; // 添加一些内边距
  });

  // 显示表头
  const headerRow = headers.map((header, index) => {
    return padString(header, colWidths[index]);
  }).join('│');

  console.log(chalk.cyan('┌' + colWidths.map(w => '─'.repeat(w)).join('┬') + '┐'));
  console.log(chalk.cyan('│') + headerRow + chalk.cyan('│'));
  console.log(chalk.cyan('├' + colWidths.map(w => '─'.repeat(w)).join('┼') + '┤'));

  // 显示数据行
  rows.forEach((row, rowIndex) => {
    const dataRow = row.map((cell, index) => {
      return padString(cell || '', colWidths[index]);
    }).join('│');
    console.log(chalk.cyan('│') + dataRow + chalk.cyan('│'));
  });

  console.log(chalk.cyan('└' + colWidths.map(w => '─'.repeat(w)).join('┴') + '┘'));
}

// 获取字符串的显示宽度（考虑中文字符）
function getDisplayWidth(str: string): number {
  let width = 0;
  for (const char of str) {
    // 简单判断：ASCII字符宽度为1，其他字符宽度为2
    width += char.charCodeAt(0) < 256 ? 1 : 2;
  }
  return width;
}

// 填充字符串到指定宽度
function padString(str: string, width: number): string {
  const currentWidth = getDisplayWidth(str);
  const padding = width - currentWidth;
  return ' ' + str + ' '.repeat(Math.max(0, padding - 1));
}

export function displayList(items: string[], numbered: boolean = false): void {
  items.forEach((item, index) => {
    const prefix = numbered ? `${index + 1}. ` : '• ';
    console.log(chalk.gray(prefix) + item);
  });
}

export function displayKeyValue(key: string, value: string): void {
  console.log(chalk.gray(`${key}: `) + chalk.white(value));
}

export function clearConsole(): void {
  process.stdout.write('\x1Bc');
}