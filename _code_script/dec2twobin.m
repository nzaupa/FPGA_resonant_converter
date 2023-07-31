function [s] = dec2twobin(d,numBits)
%DEC2TWOBIN Convert decimal integer to its twos complement representation
%   DEC2BIN(D) returns the binary representation of D as a character
%   vector. D must be an integer. If D is greater than flintmax, DEC2BIN
%   might not return an exact representation of D.
%
%   DEC2BIN(D,numBits) produces a binary representation with at least
%   numBits bits.
%
%   Example
%      dec2bin(23) returns '10111'
%
%   See also BIN2DEC, DEC2HEX, DEC2BASE, FLINTMAX.

narginchk(1,2);

if isempty(d)
    s = '';
    return;
end

if ~(isnumeric(d) || islogical(d) || ischar(d))
    error(message('MATLAB:dec2bin:InvalidDecimalArg'));
elseif ~isreal(d)
    error(message('MATLAB:dec2bin:MustBeReal'));
end

d = d(:); % Make sure d is a column vector.

if ~all(isfinite(d))
    error(message('MATLAB:dec2bin:MustBeFinite'));
end


if nargin<2
    % adapt to the number
    bin = dec2bin(abs(d));
    numBits=1+size(bin,2); % Need at least one digit even for 0.
else
    % cut the number to the maximum
    bin = dec2bin(abs(d),numBits-1);
    if size(bin,2) > numBits-1
        warning('overflow - number of bit is too small')
        s = NaN;
        return
    end
end
s = strcat('0',bin);

for k = 1:length(d)
    if d(k) <0
        num = s(k,:)-'0';
        num = not(num);
        carry = 1;
        for i = size(num,2):-1:1
            s(k,i) = num2str(xor(carry,num(i)));
            carry = and(carry,num(i));
        end
    end
end

end

