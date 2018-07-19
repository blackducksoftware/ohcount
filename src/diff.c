#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#ifdef _WIN32
# include <fcntl.h>
# define mkstemp(p) _open(_mktemp(p), _O_CREAT | _O_SHORT_LIVED | _O_EXCL)
#endif

/*
 * The bulk of this software is derived from Plan 9 and is thus distributed
 * under the Lucent Public License, Version 1.02, reproduced below.
 *
 * ===================================================================
 *
 * Lucent Public License Version 1.02
 *
 * THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS PUBLIC
 * LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR DISTRIBUTION OF THE
 * PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THIS AGREEMENT.
 *
 * 1. DEFINITIONS
 *
 * "Contribution" means:
 *
 *   a. in the case of Lucent Technologies Inc. ("LUCENT"), the Original
 *      Program, and
 *   b. in the case of each Contributor,
 *
 *      i. changes to the Program, and
 *     ii. additions to the Program;
 *
 *     where such changes and/or additions to the Program were added to the
 *     Program by such Contributor itself or anyone acting on such
 *     Contributor's behalf, and the Contributor explicitly consents, in
 *     accordance with Section 3C, to characterization of the changes and/or
 *     additions as Contributions.
 *
 * "Contributor" means LUCENT and any other entity that has Contributed a
 * Contribution to the Program.
 *
 * "Distributor" means a Recipient that distributes the Program,
 * modifications to the Program, or any part thereof.
 *
 * "Licensed Patents" mean patent claims licensable by a Contributor
 * which are necessarily infringed by the use or sale of its Contribution
 * alone or when combined with the Program.
 *
 * "Original Program" means the original version of the software
 * accompanying this Agreement as released by LUCENT, including source
 * code, object code and documentation, if any.
 *
 * "Program" means the Original Program and Contributions or any part
 * thereof
 *
 * "Recipient" means anyone who receives the Program under this
 * Agreement, including all Contributors.
 *
 * 2. GRANT OF RIGHTS
 *
 *  a. Subject to the terms of this Agreement, each Contributor hereby
 *     grants Recipient a non-exclusive, worldwide, royalty-free copyright
 *     license to reproduce, prepare derivative works of, publicly display,
 *     publicly perform, distribute and sublicense the Contribution of such
 *     Contributor, if any, and such derivative works, in source code and
 *     object code form.
 *
 *  b. Subject to the terms of this Agreement, each Contributor hereby
 *     grants Recipient a non-exclusive, worldwide, royalty-free patent
 *     license under Licensed Patents to make, use, sell, offer to sell,
 *     import and otherwise transfer the Contribution of such Contributor, if
 *     any, in source code and object code form. The patent license granted
 *     by a Contributor shall also apply to the combination of the
 *     Contribution of that Contributor and the Program if, at the time the
 *     Contribution is added by the Contributor, such addition of the
 *     Contribution causes such combination to be covered by the Licensed
 *     Patents. The patent license granted by a Contributor shall not apply
 *     to (i) any other combinations which include the Contribution, nor to
 *     (ii) Contributions of other Contributors. No hardware per se is
 *     licensed hereunder.
 *
 *  c. Recipient understands that although each Contributor grants the
 *     licenses to its Contributions set forth herein, no assurances are
 *     provided by any Contributor that the Program does not infringe the
 *     patent or other intellectual property rights of any other entity. Each
 *     Contributor disclaims any liability to Recipient for claims brought by
 *     any other entity based on infringement of intellectual property rights
 *     or otherwise. As a condition to exercising the rights and licenses
 *     granted hereunder, each Recipient hereby assumes sole responsibility
 *     to secure any other intellectual property rights needed, if any. For
 *     example, if a third party patent license is required to allow
 *     Recipient to distribute the Program, it is Recipient's responsibility
 *     to acquire that license before distributing the Program.
 *
 *  d. Each Contributor represents that to its knowledge it has sufficient
 *     copyright rights in its Contribution, if any, to grant the copyright
 *     license set forth in this Agreement.
 *
 * 3. REQUIREMENTS
 *
 * A. Distributor may choose to distribute the Program in any form under
 * this Agreement or under its own license agreement, provided that:
 *
 *  a. it complies with the terms and conditions of this Agreement;
 *
 *  b. if the Program is distributed in source code or other tangible
 *     form, a copy of this Agreement or Distributor's own license agreement
 *     is included with each copy of the Program; and
 *
 *  c. if distributed under Distributor's own license agreement, such
 *     license agreement:
 *
 *       i. effectively disclaims on behalf of all Contributors all warranties
 *          and conditions, express and implied, including warranties or
 *          conditions of title and non-infringement, and implied warranties or
 *          conditions of merchantability and fitness for a particular purpose;
 *      ii. effectively excludes on behalf of all Contributors all liability
 *          for damages, including direct, indirect, special, incidental and
 *          consequential damages, such as lost profits; and
 *     iii. states that any provisions which differ from this Agreement are
 *          offered by that Contributor alone and not by any other party.
 *
 * B. Each Distributor must include the following in a conspicuous
 *    location in the Program:
 *
 *    Copyright (C) 2003, Lucent Technologies Inc. and others. All Rights
 *    Reserved.
 *
 * C. In addition, each Contributor must identify itself as the
 * originator of its Contribution in a manner that reasonably allows
 * subsequent Recipients to identify the originator of the Contribution.
 * Also, each Contributor must agree that the additions and/or changes
 * are intended to be a Contribution. Once a Contribution is contributed,
 * it may not thereafter be revoked.
 *
 * 4. COMMERCIAL DISTRIBUTION
 *
 * Commercial distributors of software may accept certain
 * responsibilities with respect to end users, business partners and the
 * like. While this license is intended to facilitate the commercial use
 * of the Program, the Distributor who includes the Program in a
 * commercial product offering should do so in a manner which does not
 * create potential liability for Contributors. Therefore, if a
 * Distributor includes the Program in a commercial product offering,
 * such Distributor ("Commercial Distributor") hereby agrees to defend
 * and indemnify every Contributor ("Indemnified Contributor") against
 * any losses, damages and costs (collectively"Losses") arising from
 * claims, lawsuits and other legal actions brought by a third party
 * against the Indemnified Contributor to the extent caused by the acts
 * or omissions of such Commercial Distributor in connection with its
 * distribution of the Program in a commercial product offering. The
 * obligations in this section do not apply to any claims or Losses
 * relating to any actual or alleged intellectual property infringement.
 * In order to qualify, an Indemnified Contributor must: a) promptly
 * notify the Commercial Distributor in writing of such claim, and b)
 * allow the Commercial Distributor to control, and cooperate with the
 * Commercial Distributor in, the defense and any related settlement
 * negotiations. The Indemnified Contributor may participate in any such
 * claim at its own expense.
 *
 * For example, a Distributor might include the Program in a commercial
 * product offering, Product X. That Distributor is then a Commercial
 * Distributor. If that Commercial Distributor then makes performance
 * claims, or offers warranties related to Product X, those performance
 * claims and warranties are such Commercial Distributor's responsibility
 * alone. Under this section, the Commercial Distributor would have to
 * defend claims against the Contributors related to those performance
 * claims and warranties, and if a court requires any Contributor to pay
 * any damages as a result, the Commercial Distributor must pay those
 * damages.
 *
 * 5. NO WARRANTY
 *
 * EXCEPT AS EXPRESSLY SET FORTH IN THIS AGREEMENT, THE PROGRAM IS
 * PROVIDED ON AN"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, EITHER EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY
 * WARRANTIES OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY
 * OR FITNESS FOR A PARTICULAR PURPOSE. Each Recipient is solely
 * responsible for determining the appropriateness of using and
 * distributing the Program and assumes all risks associated with its
 * exercise of rights under this Agreement, including but not limited to
 * the risks and costs of program errors, compliance with applicable
 * laws, damage to or loss of data, programs or equipment, and
 * unavailability or interruption of operations.
 *
 * 6. DISCLAIMER OF LIABILITY
 *
 * EXCEPT AS EXPRESSLY SET FORTH IN THIS AGREEMENT, NEITHER RECIPIENT NOR
 * ANY CONTRIBUTORS SHALL HAVE ANY LIABILITY FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING
 * WITHOUT LIMITATION LOST PROFITS), HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OR
 * DISTRIBUTION OF THE PROGRAM OR THE EXERCISE OF ANY RIGHTS GRANTED
 * HEREUNDER, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * 7. EXPORT CONTROL
 *
 * Recipient agrees that Recipient alone is responsible for compliance
 * with the United States export administration regulations (and the
 * export control laws and regulation of any other countries).
 *
 * 8. GENERAL
 *
 * If any provision of this Agreement is invalid or unenforceable under
 * applicable law, it shall not affect the validity or enforceability of
 * the remainder of the terms of this Agreement, and without further
 * action by the parties hereto, such provision shall be reformed to the
 * minimum extent necessary to make such provision valid and enforceable.
 *
 * If Recipient institutes patent litigation against a Contributor with
 * respect to a patent applicable to software (including a cross-claim or
 * counterclaim in a lawsuit), then any patent licenses granted by that
 * Contributor to such Recipient under this Agreement shall terminate as
 * of the date such litigation is filed. In addition, if Recipient
 * institutes patent litigation against any entity (including a
 * cross-claim or counterclaim in a lawsuit) alleging that the Program
 * itself (excluding combinations of the Program with other software or
 * hardware) infringes such Recipient's patent(s), then such Recipient's
 * rights granted under Section 2(b) shall terminate as of the date such
 * litigation is filed.
 *
 * All Recipient's rights under this Agreement shall terminate if it
 * fails to comply with any of the material terms or conditions of this
 * Agreement and does not cure such failure in a reasonable period of
 * time after becoming aware of such noncompliance. If all Recipient's
 * rights under this Agreement terminate, Recipient agrees to cease use
 * and distribution of the Program as soon as reasonably practicable.
 * However, Recipient's obligations under this Agreement and any licenses
 * granted by Recipient relating to the Program shall continue and
 * survive.
 *
 * LUCENT may publish new versions (including revisions) of this
 * Agreement from time to time. Each new version of the Agreement will be
 * given a distinguishing version number. The Program (including
 * Contributions) may always be distributed subject to the version of the
 * Agreement under which it was received. In addition, after a new
 * version of the Agreement is published, Contributor may elect to
 * distribute the Program (including its Contributions) under the new
 * version. No one other than LUCENT has the right to modify this
 * Agreement. Except as expressly stated in Sections 2(a) and 2(b) above,
 * Recipient receives no rights or licenses to the intellectual property
 * of any Contributor under this Agreement, whether expressly, by
 * implication, estoppel or otherwise. All rights in the Program not
 * expressly granted under this Agreement are reserved.
 *
 * This Agreement is governed by the laws of the State of New York and
 * the intellectual property laws of the United States of America. No
 * party to this Agreement will bring a legal action under this Agreement
 * more than one year after the cause of action arose. Each party waives
 * its rights to a jury trial in any resulting litigation.
 */

#include <stdlib.h>
#include <string.h>

#include "diff.h"

struct cand {
  int x;
  int y;
  int pred;
};

struct line {
  int serial;
  int value;
};

int len[2];
struct line *file[2];
struct line *sfile[2];  // shortened by pruning common prefix and suffix
int slen[2];
int pref, suff; // length of prefix and suffix
int *class; // will be overlaid on file[0]
int *member; // will be overlaid on file[1]
int *klist; // will be overlaid on file[0] after class
struct cand *clist; // merely a free storage pot for candidates
int clen;
int *J; // will be overlaid on class

#define HALFLONG 16
#define low(x)  (x&((1L<<HALFLONG)-1))
#define high(x) (x>>HALFLONG)

/**
 * Returns a computed hash for a given string.
 * Hashing has the effect of arranging line in 7-bit bytes and then summing 1-s
 * complement in 16-bit hunks.
 * @param line The line of a buffer to hash.
 */
static int hash(char *line) {
  long sum;
  unsigned shift;
  char *p;
  int len;

  sum = 1;
  shift = 0;
  len = strlen(line);
  p = line;
  while (len--) {
    sum += (long)*p++ << (shift &= (HALFLONG-1));
    shift += 7;
  }
  sum = low(sum) + high(sum);
  return ((short)low(sum) + (short)high(sum));
}

/**
 * Hashes each line in the given string buffer and stores it internally.
 * @param i 0 for diff 'from', 1 for diff 'to'.
 * @param buf The string buffer to prepare from.
 */
void prepare(int i, const char *buf) {
  struct line *p;
  int j;
  char bufcpy[strlen(buf)];
  char *l;

  p = malloc(3*sizeof(struct line));
  j = 0;
  strncpy(bufcpy, buf, strlen(buf));
  bufcpy[strlen(buf)] = 0;
  l = strtok(bufcpy, "\n");
  while (l) {
    p = realloc(p, (++j+3)*sizeof(struct line));
    p[j].value = hash(l);
    l = strtok(NULL, "\n");
  }
  len[i] = j;
  file[i] = p;
}

/**
 * Adds to the count of lines added and removed for this diff.
 * Diff 'from' chunks are counted as lines removed and diff 'to' chunks are
 * counted as lines added.
 * @param a The diff 'from' chunk's beginning line number.
 * @param b The diff 'from' chunk's ending line number.
 * @param c The diff 'to' chunk's beginning line number.
 * @param d The diff 'to' chunk's ending line number.
 * @param added Int pointer to the running number of lines added for this diff.
 * @param removed Int pointer to the running number of lines removed for this
 *   diff.
 */
void change(int a, int b, int c, int d, int *added, int *removed) {
  if (a > b && c > d)
    return;

  if(a <= 1)
    a = 1;
  if(b > len[0])
    b = len[0];
  if(a <= b)
    *removed += b - a + 1;

  if(c <= 1)
    c = 1;
  if(d > len[1])
    d = len[1];
  if(c <= d)
    *added += d - c + 1;
}

/*
 * diff - differential file comparison
 *
 * Uses an algorithm due to Harold Stone, which finds
 * a pair of longest identical subsequences in the two
 * files.
 *
 * The major goal is to generate the match vector J.
 * J[i] is the index of the line in file1 corresponding
 * to line i file0. J[i] = 0 if there is no
 * such line in file1.
 *
 * Lines are hashed so as to work in core. All potential
 * matches are located by sorting the lines of each file
 * on the hash (called value). In particular, this
 * collects the equivalence classes in file1 together.
 * Subroutine equiv replaces the value of each line in
 * file0 by the index of the first element of its
 * matching equivalence in (the reordered) file1.
 * To save space equiv squeezes file1 into a single
 * array member in which the equivalence classes
 * are simply concatenated, except that their first
 * members are flagged by changing sign.
 *
 * Next the indices that point into member are unsorted into
 * array class according to the original order of file0.
 *
 * The cleverness lies in routine stone. This marches
 * through the lines of file0, developing a vector klist
 * of "k-candidates". At step i a k-candidate is a matched
 * pair of lines x,y (x in file0 y in file1) such that
 * there is a common subsequence of lenght k
 * between the first i lines of file0 and the first y
 * lines of file1, but there is no such subsequence for
 * any smaller y. x is the earliest possible mate to y
 * that occurs in such a subsequence.
 *
 * Whenever any of the members of the equivalence class of
 * lines in file1 matable to a line in file0 has serial number
 * less than the y of some k-candidate, that k-candidate
 * with the smallest such y is replaced. The new
 * k-candidate is chained (via pred) to the current
 * k-1 candidate so that the actual subsequence can
 * be recovered. When a member has serial number greater
 * that the y of all k-candidates, the klist is extended.
 * At the end, the longest subsequence is pulled out
 * and placed in the array J by unravel.
 *
 * With J in hand, the matches there recorded are
 * check'ed against reality to assure that no spurious
 * matches have crept in due to hashing. If they have,
 * they are broken, and "jackpot " is recorded--a harmless
 * matter except that a true match for a spuriously
 * mated line may now be unnecessarily reported as a change.
 *
 * Much of the complexity of the program comes simply
 * from trying to minimize core utilization and
 * maximize the range of doable problems by dynamically
 * allocating what is needed and reusing what is not.
 * The core requirements for problems larger than somewhat
 * are (in words) 2*length(file0) + length(file1) +
 * 3*(number of k-candidates installed),  typically about
 * 6n words for files of length n.
 */

static void sort(struct line *a, int n) { /*shellsort CACM #201*/
  int m;
  struct line *ai, *aim, *j, *k;
  struct line w;
  int i;

  m = 0;
  for (i = 1; i <= n; i *= 2)
    m = 2*i - 1;
  for (m /= 2; m != 0; m /= 2) {
    k = a+(n-m);
    for (j = a+1; j <= k; j++) {
      ai = j;
      aim = ai+m;
      do {
        if (aim->value > ai->value ||
           aim->value == ai->value &&
           aim->serial > ai->serial)
          break;
        w = *ai;
        *ai = *aim;
        *aim = w;

        aim = ai;
        ai -= m;
      } while (ai > a && aim >= ai);
    }
  }
}

static void unsort(struct line *f, int l, int *b) {
  int *a;
  int i;

  a = malloc((l+1)*sizeof(int));
  for(i=1;i<=l;i++)
    a[f[i].serial] = f[i].value;
  for(i=1;i<=l;i++)
    b[i] = a[i];
  free(a);
}

static void prune(void) {
  int i, j;

  for(pref=0;pref<len[0]&&pref<len[1]&&
    file[0][pref+1].value==file[1][pref+1].value;
    pref++ ) ;
  for(suff=0;suff<len[0]-pref&&suff<len[1]-pref&&
    file[0][len[0]-suff].value==file[1][len[1]-suff].value;
    suff++) ;
  for(j=0;j<2;j++) {
    sfile[j] = file[j]+pref;
    slen[j] = len[j]-pref-suff;
    for(i=0;i<=slen[j];i++)
      sfile[j][i].serial = i;
  }
}

static void equiv(struct line *a, int n, struct line *b, int m, int *c) {
  int i, j;

  i = j = 1;
  while(i<=n && j<=m) {
    if(a[i].value < b[j].value)
      a[i++].value = 0;
    else if(a[i].value == b[j].value)
      a[i++].value = j;
    else
      j++;
  }
  while(i <= n)
    a[i++].value = 0;
  b[m+1].value = 0;
  j = 0;
  while(++j <= m) {
    c[j] = -b[j].serial;
    while(b[j+1].value == b[j].value) {
      j++;
      c[j] = b[j].serial;
    }
  }
  c[j] = -1;
}

static int newcand(int x, int  y, int pred) {
  struct cand *q;

  clist = realloc(clist, (clen+1)*sizeof(struct cand));
  q = clist + clen;
  q->x = x;
  q->y = y;
  q->pred = pred;
  return clen++;
}

static int search(int *c, int k, int y) {
  int i, j, l;
  int t;

  if(clist[c[k]].y < y)   /*quick look for typical case*/
    return k+1;
  i = 0;
  j = k+1;
  while((l=(i+j)/2) > i) {
    t = clist[c[l]].y;
    if(t > y)
      j = l;
    else if(t < y)
      i = l;
    else
      return l;
  }
  return l+1;
}

static int stone(int *a, int n, int *b, int *c) {
  int i, k, y;
  int j, l;
  int oldc, tc;
  int oldl;

  k = 0;
  c[0] = newcand(0,0,0);
  for(i=1; i<=n; i++) {
    j = a[i];
    if(j==0)
      continue;
    y = -b[j];
    oldl = 0;
    oldc = c[0];
    do {
      if(y <= clist[oldc].y)
        continue;
      l = search(c, k, y);
      if(l!=oldl+1)
        oldc = c[l-1];
      if(l<=k) {
        if(clist[c[l]].y <= y)
          continue;
        tc = c[l];
        c[l] = newcand(i,y,oldc);
        oldc = tc;
        oldl = l;
      } else {
        c[l] = newcand(i,y,oldc);
        k++;
        break;
      }
    } while((y=b[++j]) > 0);
  }
  return k;
}

static void unravel(int p) {
  int i;
  struct cand *q;

  for(i=0; i<=len[0]; i++) {
    if (i <= pref)
      J[i] = i;
    else if (i > len[0]-suff)
      J[i] = i+len[1]-len[0];
    else
      J[i] = 0;
  }
  for(q=clist+p;q->y!=0;q=clist+q->pred)
    J[q->x+pref] = q->y+pref;
}

static void output(int *added, int *removed) {
  int m, i0, i1, j0, j1;

  m = len[0];
  J[0] = 0;
  J[m+1] = len[1]+1;
  for (i0 = 1; i0 <= m; i0 = i1+1) {
    while (i0 <= m && J[i0] == J[i0-1]+1)
      i0++;
    j0 = J[i0-1]+1;
    i1 = i0-1;
    while (i1 < m && J[i1+1] == 0)
      i1++;
    j1 = J[i1+1]-1;
    J[i1] = j1;
    change(i0, i1, j0, j1, added, removed);
  }
  if (m == 0)
    change(1, 0, 1, len[1], added, removed);
}

// create and return the path of a tmp_file filled with buf
// caller must delete file if that's desired
char *tmp_file_from_buf(const char *buf) {
	char *template = "/tmp/ohcount_diff_XXXXXXX";
	char *path = strdup(template);

	int fd = mkstemp(path);
  if (write(fd, buf, strlen(buf)) != strlen(buf)) {
    fprintf(stderr, "src/diff.c: Could not write temporary file %s.\n", path);
    exit(1);
  }
	close(fd);
	return path;
}

#ifndef errno
extern int errno;
#endif

void ohcount_calc_diff_with_disk(
		const char *from,
		const char *to,
		int *added,
		int *removed) {
	*added = *removed = 0;
	char *from_tmp = tmp_file_from_buf(from);
	char *to_tmp = tmp_file_from_buf(to);

	char command[1000];
	sprintf(command, "diff -d --normal  --suppress-common-lines --new-file '%s' '%s'", from_tmp, to_tmp);
	FILE *f = popen(command, "r");
	if (f) {
		char line[10000];
		while(fgets(line, sizeof(line), f)) {
			if (line[0] == '>')
			 	(*added)++;
			if (line[0] == '<')
				(*removed)++;
		}
	}
	pclose(f);
	if (remove(from_tmp)) {
		printf("error unlinking %s: %d", from_tmp, errno);
	}
	if (remove(to_tmp)) {
		printf("error unlinking %s: %d", from_tmp, errno);
	}
}

#define USE_DISK_IF_LARGER 100000
void ohcount_calc_diff(const char *from,
	 	const char *to, int *added, int *removed) {
  int k;

	if (strlen(from) > USE_DISK_IF_LARGER || strlen(to) > USE_DISK_IF_LARGER)
		return ohcount_calc_diff_with_disk(from, to, added, removed);

  prepare(0, from);
  prepare(1, to);
  clen = 0;
  prune();
  sort(sfile[0], slen[0]);
  sort(sfile[1], slen[1]);

  member = (int *)file[1];
  equiv(sfile[0], slen[0], sfile[1], slen[1], member);
  member = realloc(member, (slen[1]+2)*sizeof(int));

  class = (int *)file[0];
  unsort(sfile[0], slen[0], class);
  class = realloc(class, (slen[0]+2)*sizeof(int));

  klist = malloc((slen[0]+2)*sizeof(int));
  clist = malloc(sizeof(struct cand));
  k = stone(class, slen[0], member, klist);
  free(member);
  free(class);

  J = malloc((len[0]+2)*sizeof(int));
  unravel(klist[k]);
  free(clist);
  free(klist);

  *added = *removed = 0;
  output(added, removed);
  free(J);
}
